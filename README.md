# docker-openvpn2socks5

将OpenVPN连接转换为SOCKS5代理的Docker镜像，基于[官方OpenVPN客户端](https://openvpn.net/)和[tun2socks](https://github.com/xjasonlyu/tun2socks)项目。

## 功能

- 使用官方OpenVPN客户端连接到OpenVPN服务器
- 通过tun2socks将VPN流量转换为SOCKS5代理
- 支持用户名/密码认证
- 轻量级Debian基础镜像

## 构建镜像

```bash
docker build -t openvpn2socks5 .
```

## 使用方法

### 基本用法

```bash
docker run --rm -it --cap-add=NET_ADMIN \
  -v /path/to/your/config.ovpn:/config.ovpn \
  -p 1080:1080 \
  openvpn2socks5 --config /config.ovpn
```

### 带用户名和密码的认证

```bash
docker run --rm -it --cap-add=NET_ADMIN \
  -v /path/to/your/config.ovpn:/config.ovpn \
  -p 1080:1080 \
  openvpn2socks5 --config /config.ovpn --username your_username --password your_password
```

### 自定义SOCKS5端口

```bash
docker run --rm -it --cap-add=NET_ADMIN \
  -v /path/to/your/config.ovpn:/config.ovpn \
  -p 8888:8888 \
  openvpn2socks5 --config /config.ovpn --socks-addr 0.0.0.0:8888
```

## 参数说明

- `-c, --config FILE`: OpenVPN配置文件路径（必需）
- `-u, --username USER`: OpenVPN用户名
- `-p, --password PASS`: OpenVPN密码
- `-s, --socks-addr ADDR`: SOCKS5服务器地址（默认为0.0.0.0:1080）
- `-h, --help`: 显示帮助信息

## 注意事项

- 容器需要`--cap-add=NET_ADMIN`权限来创建和管理TUN设备
- 建议使用`--rm`参数，以便容器停止时自动删除
- 使用`-d`参数可以在后台运行容器

## 许可证

MIT 