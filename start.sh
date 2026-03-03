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

# 【黑科技】定向源码补丁：仅处理编译后的核心代码，极大缩短启动时间
echo "Patching core distribution files for Telegram API..."
# 1. 处理 dist 目录下的核心逻辑
find /app/dist -type f -name "*.js" -exec sed -i "s|api.telegram.org|$TG_PROXY_DOMAIN|g" {} + || true
# 2. 定向处理常见的 Telegram 库 (telegraf / node-telegram-bot-api)
if [ -d "/app/node_modules/telegraf" ]; then
    find /app/node_modules/telegraf -type f -name "*.js" -exec sed -i "s|api.telegram.org|$TG_PROXY_DOMAIN|g" {} + || true
fi

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

# 启动命令：后台运行网关，然后使用 tail -f 维持容器运行并实时输出日志
echo "Starting Gateway via daemon-cli..."
# 确保日志目录存在，并创建一个初始文件防止 tail 崩溃
mkdir -p "$CONF_DIR/logs"
touch "$CONF_DIR/logs/system.log"

node dist/daemon-cli.js gateway --port 7860 --bind 0.0.0.0 --allow-unconfigured &

# 等待应用初始化
sleep 5
echo "Streaming logs to keep container alive..."
# 加上 -F (Retry) 确保如果文件还没生成也会等待
exec tail -F "$CONF_DIR/logs/"*.log 2>/dev/null || sleep infinity
