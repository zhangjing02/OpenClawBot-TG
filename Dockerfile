# 基于社区成熟镜像 coollabsio/openclaw
# 已内置：配置管理、nginx 反代、进程守护、Telegram 频道支持
FROM coollabsio/openclaw:latest

# Hugging Face 要求监听 7860 端口
ENV PORT=7860

# 复制 Telegram API 代理补丁脚本
COPY init.sh /app/scripts/init.sh
RUN chmod +x /app/scripts/init.sh

# 设置自定义初始化脚本（在 OpenClaw 启动前执行）
ENV OPENCLAW_DOCKER_INIT_SCRIPT=/app/scripts/init.sh

EXPOSE 7860
