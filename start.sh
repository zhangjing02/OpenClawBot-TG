#!/bin/bash
set -e

# 设置配置存储路径 (OpenClaw 2026.3)
CONF_DIR="/root/.openclaw"
mkdir -p "$CONF_DIR"
mkdir -p "/app/storage/workspace"

echo "Finalizing OpenClaw 2026.3.2 connectivity..."

# 获取 Token
TOKEN="${TG_TOKEN:-8706533687:AAHQIxNouxWxn2HM2Ita2w7B8_CkKda4nio}"

# 生成极简配置文件
# 仅保留核心代理和频道设置，彻底移除所有不兼容的网络配置键
cat > "$CONF_DIR/openclaw.json" <<EOF
{
  "gateway": {
    "mode": "local",
    "port": 7860
  },
  "agents": {
    "defaults": {
      "workspace": "/app/storage/workspace"
    }
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "$TOKEN"
    }
  }
}
EOF

# 【关键点】在 2026.3 版本中，通过环境变量强制绑定所有接口
export HOST="0.0.0.0"
export OPENCLAW_HOST="0.0.0.0"
export OPENCLAW_PORT=7860
# 禁用 Webhook，强制使用 Polling 以避免在 HF 环境下的复杂反代问题
export OPENCLAW_TELEGRAM_BOT_TOKEN="$TOKEN"
export TELEGRAM_BOT_TOKEN="$TOKEN"

echo "Starting Gateway on 0.0.0.0:7860..."

# 启动命令：使用 --host 参数（如果命令支持）并增加 printf 作为冗余
# 同时保留 --allow-unconfigured 绕过向导
printf "\n\n\n\n\n\n" | node scripts/run-node.mjs gateway --port 7860 --host 0.0.0.0 --allow-unconfigured
