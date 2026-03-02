#!/bin/bash

# 确保配置目录存在
mkdir -p /app/storage/config

# 如果环境变量中提供了 Telegram Token，则将其注入到 OpenClaw 配置中
# 注意：这只是一个示例逻辑，OpenClaw 实际可能通过直接读取环境变量或 config.yaml 运行
# 我们直接启动 Gateway 服务，OpenClaw 会优先读取系统环境变量

echo "Starting OpenClaw Gateway on port 7860..."

# 设置应用端口为 Hugging Face 要求的 7860
export PORT=7860

# 启动 OpenClaw
# 自动回答交互式向导 (网关、工作区、技能设置)
# 根据 OpenClaw 的向导逻辑，通常需要几个回车或默认选择
printf "\n\n\n\n\n\n" | npm run start -- --port $PORT
