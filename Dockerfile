FROM debian:bookworm-slim

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
    iptables \
    openvpn

# 安装 Go 1.23.7 (用于编译tun2socks)
RUN wget https://go.dev/dl/go1.23.7.linux-arm64.tar.gz && \
    tar -C /usr/local -xzf go1.23.7.linux-arm64.tar.gz && \
    rm go1.23.7.linux-arm64.tar.gz

# 设置Go环境变量
ENV PATH=$PATH:/usr/local/go/bin
ENV GOPATH=/go
ENV GOROOT=/usr/local/go

# 创建工作目录
WORKDIR /app

# 编译 tun2socks
RUN git clone https://github.com/xjasonlyu/tun2socks.git && \
    cd tun2socks && \
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