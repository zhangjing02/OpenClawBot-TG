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

# 【黑科技】源码补丁：在启动前替换所有硬编码的官方域名
# 使用 grep 预筛选，极大提升启动速度；改用 | 作为 sed 分隔符以支持包含 / 的代理地址
echo "Scanning and patching source files for Telegram API..."
grep -rl "api.telegram.org" /app/dist /app/node_modules --include="*.js" 2>/dev/null | xargs -r sed -i "s|api.telegram.org|$TG_PROXY_DOMAIN|g" || true

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
# 加上 exec 确保进程接管 PID 1，以便接收 HF 的停止信号并防止提前退出
exec node dist/daemon-cli.js gateway --port 7860 --bind 0.0.0.0 --allow-unconfigured
