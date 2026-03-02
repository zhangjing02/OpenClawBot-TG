#!/bin/bash
set -e

# 设置配置存储路径 (OpenClaw 2026.3)
CONF_DIR="/root/.openclaw"
mkdir -p "$CONF_DIR"
mkdir -p "/app/storage/workspace"

echo "Applying deep source patching for Telegram connectivity..."

# 获取 Token
TOKEN="${TG_TOKEN:-8706533687:AAHQIxNouxWxn2HM2Ita2w7B8_CkKda4nio}"

# 配置 Telegram API 反向代理地址 (高可靠节点)
TG_PROXY_DOMAIN="tgproxy.liblaf.top/bot"

# 【黑科技】源码打桩：在启动前替换所有硬编码的官方域名
# 这样即便配置参数无效，底层通信也会强制流向代理
echo "Patching source files to use $TG_PROXY_DOMAIN..."
find /app/node_modules -type f -name "*.js" -exec sed -i "s/api.telegram.org/$TG_PROXY_DOMAIN/g" {} + || true
find /app/dist -type f -name "*.js" -exec sed -i "s/api.telegram.org/$TG_PROXY_DOMAIN/g" {} + || true

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
      "botToken": "$TOKEN"
    }
  }
}
EOF

# 环境变量设置
export OPENCLAW_GATEWAY_BIND="lan"
export OPENCLAW_GATEWAY_PORT=7860
export OPENCLAW_TELEGRAM_BOT_TOKEN="$TOKEN"
export TELEGRAM_BOT_TOKEN="$TOKEN"
export NODE_TLS_REJECT_UNAUTHORIZED=0

echo "Starting Gateway via daemon-cli..."

# 启动命令：使用 subagent 验证成功的确切路径
# 注意：2026.3 版本的入口点可能是 dist/daemon-cli.js
node dist/daemon-cli.js gateway --port 7860 --bind 0.0.0.0 --allow-unconfigured
