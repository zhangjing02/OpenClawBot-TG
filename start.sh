#!/bin/bash
set -e

# 设置配置存储路径 (OpenClaw 2026.3 默认位置)
CONF_DIR="/root/.openclaw"
mkdir -p "$CONF_DIR"
mkdir -p "/app/storage/workspace"

echo "Finalizing OpenClaw 2026.3 configuration..."

# 获取 Token (支持手动输入或环境变量)
TOKEN="${TG_TOKEN:-8706533687:AAHQIxNouxWxn2HM2Ita2w7B8_CkKda4nio}"

# 生成严格符合 2026.3.2 规范的配置文件
# 注意：新版本使用 botToken 且去除了过时的 gateway 网络配置项
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

# 通过环境变量注入，这是最可靠的备选方案
export PORT=7860
export TELEGRAM_BOT_TOKEN="$TOKEN"
export OPENCLAW_TELEGRAM_BOT_TOKEN="$TOKEN"

echo "Starting Gateway..."

# 启动命令：移除不再支持的 --listen 参数，使用官方推荐的 --allow-unconfigured
# 配合 printf 以防万一仍有向导弹出
printf "\n\n\n\n\n\n" | node scripts/run-node.mjs gateway --port 7860 --allow-unconfigured
