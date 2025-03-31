#!/bin/bash
set -e

# 加载配置
source /app/config.sh

# 显示帮助信息
function show_help {
    echo "使用方法: docker run --cap-add=NET_ADMIN [选项] 镜像名称"
    echo ""
    echo "选项:"
    echo "  -c, --config FILE     OpenVPN配置文件路径"
    echo "  -u, --username USER   OpenVPN用户名"
    echo "  -p, --password PASS   OpenVPN密码"
    echo "  -s, --socks-addr ADDR SOCKS5服务器地址 (默认 0.0.0.0:1080)"
    echo "  -h, --help            显示帮助信息"
    exit 0
}

# 解析参数
CONFIG_FILE=""
USERNAME=""
PASSWORD=""
SOCKS_ADDR="0.0.0.0:1080"

while [[ $# -gt 0 ]]; do
    case "$1" in
        -c|--config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        -u|--username)
            USERNAME="$2"
            shift 2
            ;;
        -p|--password)
            PASSWORD="$2"
            shift 2
            ;;
        -s|--socks-addr)
            SOCKS_ADDR="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo "未知选项: $1"
            show_help
            ;;
    esac
done

# 检查必需参数
if [ -z "$CONFIG_FILE" ]; then
    echo "错误: 必须指定OpenVPN配置文件"
    show_help
fi

# 创建TUN设备
mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
    chmod 600 /dev/net/tun
fi

# 启动minivpn
CREDENTIALS=""
if [ ! -z "$USERNAME" ] && [ ! -z "$PASSWORD" ]; then
    echo "$USERNAME" > /tmp/credentials
    echo "$PASSWORD" >> /tmp/credentials
    CREDENTIALS="--auth-user-pass /tmp/credentials"
fi

# 在后台启动minivpn
echo "启动minivpn..."
minivpn -config "$CONFIG_FILE" $CREDENTIALS --tun-name tun0 &
MINIVPN_PID=$!

# 等待TUN设备准备就绪
echo "等待TUN设备就绪..."
while ! ip link show tun0 >/dev/null 2>&1; do
    sleep 1
done

# 配置TUN设备
ip link set tun0 up

# 启动tun2socks
echo "启动tun2socks..."
tun2socks -device tun0 -proxy socks5://$SOCKS_ADDR &
TUN2SOCKS_PID=$!

# 捕获信号
trap "kill $MINIVPN_PID $TUN2SOCKS_PID 2>/dev/null; exit" SIGINT SIGTERM

echo "服务已启动 - SOCKS5代理运行在 $SOCKS_ADDR"
echo "按Ctrl+C停止服务..."

# 等待子进程
wait $MINIVPN_PID $TUN2SOCKS_PID 