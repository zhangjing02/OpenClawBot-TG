#!/bin/bash
set -e

# 设置配置存储路径
CONF_DIR="/root/.openclaw"
mkdir -p "$CONF_DIR"
mkdir -p "/app/storage/workspace"

echo "Applying final network configuration..."

# 获取 Token
TOKEN="${TG_TOKEN:-8706533687:AAHQIxNouxWxn2HM2Ita2w7B8_CkKda4nio}"

# 生成配置文件，同时尝试多种可能的监听配置键
cat > "$CONF_DIR/openclaw.json" <<EOF
{
  "gateway": {
    "mode": "local",
    "port": 7860,
    "host": "0.0.0.0",
    "listen": "0.0.0.0:7860"
  },
  "agents": {
    "defaults": {
      "workspace": "/app/storage/workspace"
    }
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "token": "$TOKEN"
    }
  },
  "providers": {
    "zero": {
      "enabled": true,
      "browser": "playwright",
      "headless": true
    }
  }
}
EOF

# 设置环境变量 (HF Space 识别 PORT 环境变量)
export PORT=7860
export HOST="0.0.0.0"
export OPENCLAW_LISTEN="0.0.0.0:7860"
export OPENCLAW_PORT=7860

echo "Starting OpenClaw Gateway on 0.0.0.0:7860..."

# 启动命令：增加 --listen 和 --port 参数强制覆盖
printf "\n\n\n\n\n\n" | node scripts/run-node.mjs gateway --port 7860 --listen 0.0.0.0:7860 --allow-unconfigured
