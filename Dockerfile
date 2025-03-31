FROM --platform=linux/amd64 debian:bookworm-slim

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive

# 安装依赖
RUN apt-get update && apt-get install -y \
    git \
    gcc \
    g++ \
    make \
    wget \
    ca-certificates \
    iproute2 \
    iptables

# 安装 Go 1.20.14 (用于编译minivpn)
RUN wget https://go.dev/dl/go1.20.14.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.20.14.linux-amd64.tar.gz && \
    rm go1.20.14.linux-amd64.tar.gz && \
    mv /usr/local/go /usr/local/go1.20

# 安装 Go 1.23.7 (用于编译tun2socks)
RUN wget https://go.dev/dl/go1.23.7.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.23.7.linux-amd64.tar.gz && \
    rm go1.23.7.linux-amd64.tar.gz && \
    mv /usr/local/go /usr/local/go1.23

# 创建工作目录
WORKDIR /app

# 编译 minivpn (使用 Go 1.20.14)
RUN git clone https://github.com/ooni/minivpn.git && \
    cd minivpn && \
    PATH=/usr/local/go1.20/bin:$PATH GOPATH=/go1.20 GOROOT=/usr/local/go1.20 \
    go build -o /usr/local/bin/minivpn ./cmd/minivpn && \
    cd .. && \
    rm -rf minivpn

# 编译 tun2socks (使用 Go 1.23.7)
RUN git clone https://github.com/xjasonlyu/tun2socks.git && \
    cd tun2socks && \
    PATH=/usr/local/go1.23/bin:$PATH GOPATH=/go1.23 GOROOT=/usr/local/go1.23 \
    go build -o /usr/local/bin/tun2socks && \
    cd .. && \
    rm -rf tun2socks

# 复制启动脚本和配置文件
COPY start.sh /app/
COPY config.sh /app/

# 设置脚本权限
RUN chmod +x /app/start.sh /app/config.sh

# 设置 ENTRYPOINT
ENTRYPOINT ["/app/start.sh"]

# 暴露 SOCKS5 端口
EXPOSE 1080

# 默认命令
CMD ["--help"] 