#!/bin/bash

# 版本信息
VERSION="1.0.0"

# 默认路径
DEFAULT_CONFIG_DIR="/config"

# 最大重连次数
MAX_RECONNECT=5

# tun2socks相关配置
TUN_MTU=1500
TUN_NAME="tun0"

# 日志级别 (debug, info, warning, error)
LOG_LEVEL="info"

# 输出版本信息
function print_version {
  echo "docker-openvpn2socks5 v$VERSION"
  echo "使用 OpenVPN 和 tun2socks 将 OpenVPN 转换为 SOCKS5 代理"
}

# 检查Docker容器运行环境
function check_environment {
  if [ ! -d "/dev/net" ]; then
    echo "警告: 没有找到 /dev/net 目录，尝试创建"
    mkdir -p /dev/net
  fi
  
  if [ ! -c "/dev/net/tun" ]; then
    echo "警告: 没有找到 /dev/net/tun 设备，尝试创建"
    echo "注意: 这需要 --cap-add=NET_ADMIN 权限"
  fi
}

# 打印调试信息的函数
function debug_log {
  if [ "$LOG_LEVEL" == "debug" ]; then
    echo "[DEBUG] $1"
  fi
}

# 打印信息的函数
function info_log {
  if [ "$LOG_LEVEL" == "debug" ] || [ "$LOG_LEVEL" == "info" ]; then
    echo "[INFO] $1"
  fi
}

# 打印警告的函数
function warning_log {
  if [ "$LOG_LEVEL" == "debug" ] || [ "$LOG_LEVEL" == "info" ] || [ "$LOG_LEVEL" == "warning" ]; then
    echo "[WARNING] $1"
  fi
}

# 打印错误的函数
function error_log {
  echo "[ERROR] $1"
}

# 检查环境
check_environment 