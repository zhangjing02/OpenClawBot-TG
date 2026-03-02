# 使用 Node.js 22 官方镜像 (基于 Debian Bookworm)
FROM node:22-bookworm

# 设置工作目录
WORKDIR /app

# 安装基础工具
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# 安装 pnpm
RUN npm install -g pnpm

# 安装 Bun (用于 OpenClaw 构建)
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:$PATH"

# 克隆 OpenClaw 源码
RUN git clone https://github.com/openclaw/openclaw.git .

# 安装项目依赖并构建
RUN bun install
RUN bun run build

# 安装 Playwright 并由其自动安装系统依赖
# install-deps 会自动调用 apt-get 安装正确的库文件 (如 libgbm1, libasound2 等)
RUN npx playwright install chromium
RUN npx playwright install-deps chromium

# 创建存储目录并设置权限
RUN mkdir -p /app/storage/workspace /app/storage/config /root/.openclaw && \
    chmod -R 777 /app/storage /root/.openclaw

# 暴露 Hugging Face 默认端口
EXPOSE 7860

# 复制启动脚本并设置执行权限
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# 启动命令
CMD ["/app/start.sh"]
