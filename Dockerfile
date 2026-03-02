# 使用 Node.js 22 官方镜像
FROM node:22-bookworm

# 设置工作目录
WORKDIR /app

# 安装必要的系统依赖
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g pnpm && \
    curl -fsSL https://bun.sh/install | bash && \
    ln -s $HOME/.bun/bin/bun /usr/local/bin/bun && \
    rm -rf /var/lib/apt/lists/*

# 安装 Bun (OpenClaw 构建所需)
ENV PATH="/root/.bun/bin:$PATH"

# 安装 Playwright 浏览器依赖 (用于 Zero Token 模式模拟网页登录)
RUN npx -y playwright install-deps chromium

# 克隆 OpenClaw 源码 (直接拉取最新稳定版)
RUN git clone https://github.com/openclaw/openclaw.git .

# 安装项目依赖并构建
RUN bun install
RUN bun run build

# 创建存储目录并设置权限 (Hugging Face 用户 ID 为 1000)
RUN mkdir -p /app/storage/workspace /app/storage/config && \
    chmod -R 777 /app/storage

# 暴露 Hugging Face 默认端口
EXPOSE 7860

# 复制启动脚本并设置执行权限
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# 启动命令
CMD ["/app/start.sh"]
