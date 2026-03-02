# 使用 Node.js 22 官方镜像 (基于 Debian Bookworm，兼容性好)
FROM node:22-bookworm

# 设置工作目录
WORKDIR /app

# 安装系统级依赖：git, curl, 以及 Playwright 所需的库
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    libgbm-dev \
    libnss3 \
    libasound2 \
    libxshmfence1 \
    libxrender1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext1 \
    libxi6 \
    libxtst6 \
    libpangocairo-1.0-0 \
    libpango-1.0-0 \
    libatk1.0-0 \
    libcairo-gobject2 \
    libcairo2 \
    libgdk-pixbuf2.0-0 \
    libglib2.0-0 \
    libgtk-3-0 \
    && rm -rf /var/lib/apt/lists/*

# 全局安装 pnpm
RUN npm install -g pnpm

# 安装 Bun (用于 OpenClaw 构建)
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:$PATH"

# 克隆 OpenClaw 源码 (直接拉取官方仓库)
RUN git clone https://github.com/openclaw/openclaw.git .

# 安装项目依赖并构建 (OpenClaw 使用立项级多构建步骤)
RUN bun install
RUN bun run build

# 安装 Playwright 浏览器 (用于 Zero Token 模式模拟网页登录顶级模型)
# 我们只安装 chromium 以节省空间
RUN npx playwright install chromium

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
