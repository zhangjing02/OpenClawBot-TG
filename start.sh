#!/bin/bash
set -e

# 设置配置存储路径 (OpenClaw 2026.3)
CONF_DIR="/root/.openclaw"
mkdir -p "$CONF_DIR"
mkdir -p "/app/storage/workspace"

echo "Finalizing OpenClaw 2026.3.2 connectivity with Proxy & lan bind..."

# 获取 Token
TOKEN="${TG_TOKEN:-8706533687:AAHQIxNouxWxn2HM2Ita2w7B8_CkKda4nio}"

# 配置 Telegram API 反向代理地址 (解决 HF 网络封锁)
# 使用常用的公开反代地址或自建反代，这里推荐配置环境变量
# OpenClaw 支持自定义 apiRoot
TG_API_BASE="https://tgproxy.org" 

# 生成极简配置文件
# 增加 apiRoot 参数以绕过 api.telegram.org 的直接访问限制
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
      "botToken": "$TOKEN",
      "apiRoot": "$TG_API_BASE"
    }
  }
}
EOF

# 【关键点】环境变量双重设置
export OPENCLAW_GATEWAY_BIND="lan"
export OPENCLAW_GATEWAY_PORT=7860
export OPENCLAW_TELEGRAM_BOT_TOKEN="$TOKEN"
export TELEGRAM_BOT_TOKEN="$TOKEN"
# 某些库可能支持通过此变量修改 API 地址
export TELEGRAM_API_ROOT="$TG_API_BASE"

echo "Starting Gateway with bind:lan and TG Proxy: $TG_API_BASE..."

# 启动命令
printf "\n\n\n\n\n\n" | node scripts/run-node.mjs gateway --port 7860 --bind lan --allow-unconfigured
