#!/bin/bash
set -e

# 设置配置存储路径 (OpenClaw 2026.3)
CONF_DIR="/root/.openclaw"
mkdir -p "$CONF_DIR"
mkdir -p "/app/storage/workspace"

echo "Finalizing OpenClaw 2026.3.2 connectivity with 'lan' bind mode..."

# 获取 Token
TOKEN="${TG_TOKEN:-8706533687:AAHQIxNouxWxn2HM2Ita2w7B8_CkKda4nio}"

# 生成极简配置文件
# 使用 2026.3+ 推荐的 bind: "lan" 来代替直接指定 0.0.0.0
cat > "$CONF_DIR/openclaw.json" <<EOF
{
  "gateway": {
    "mode": "local",
    "bind": "lan",
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

# 【关键点】在 2026.3 版本中，通过特定的环境变量强制绑定所有接口
export OPENCLAW_GATEWAY_BIND="lan"
export OPENCLAW_GATEWAY_PORT=7860
export OPENCLAW_TELEGRAM_BOT_TOKEN="$TOKEN"
export TELEGRAM_BOT_TOKEN="$TOKEN"

echo "Starting Gateway with bind:lan on port 7860..."

# 启动命令：使用 --bind lan 参数（命令行参数权重最高）
# 移除之前报错的 --host 参数
printf "\n\n\n\n\n\n" | node scripts/run-node.mjs gateway --port 7860 --bind lan --allow-unconfigured
