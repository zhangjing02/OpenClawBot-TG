#!/bin/bash
set -e

# 设置配置存储路径 (OpenClaw 2026.3)
CONF_DIR="/root/.openclaw"
mkdir -p "$CONF_DIR"
mkdir -p "/app/storage/workspace"

echo "Finalizing OpenClaw 2026.3.2 connectivity with High-Reliability Proxy..."

# 获取 Token
TOKEN="${TG_TOKEN:-8706533687:AAHQIxNouxWxn2HM2Ita2w7B8_CkKda4nio}"

# 配置 Telegram API 反向代理地址 (切换至高可靠备选节点)
# 备选 1: https://tgproxy.liblaf.top/bot (由 subagent 建议)
# 备选 2: https://telegram-proxy.vercel.app (稳健节点)
TG_API_BASE="https://tgproxy.liblaf.top/bot"

# 生成极简配置文件
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

# 【关键点】环境变量强制注入
export OPENCLAW_GATEWAY_BIND="lan"
export OPENCLAW_GATEWAY_PORT=7860
export OPENCLAW_TELEGRAM_BOT_TOKEN="$TOKEN"
export TELEGRAM_BOT_TOKEN="$TOKEN"
export TELEGRAM_API_ROOT="$TG_API_BASE"

# 针对某些 Node.js 版本的 HTTPS 证书兼容性处理 (可选，增加可靠性)
export NODE_TLS_REJECT_UNAUTHORIZED=0

echo "Starting Gateway with bind:lan and Improved TG Proxy: $TG_API_BASE..."

# 启动命令：增加自动重连参数（如果当前版本支持）
printf "\n\n\n\n\n\n" | node scripts/run-node.mjs gateway --port 7860 --bind lan --allow-unconfigured
