#!/bin/bash
set -e

# 设置配置存储路径 (兼容多种可能的默认位置)
CONF_DIR="/root/.openclaw"
CONF_FILE="$CONF_DIR/openclaw.json"
STORAGE_DIR="/app/storage"

echo "Setting up OpenClaw configuration..."

# 创建必要目录
mkdir -p "$CONF_DIR"
mkdir -p "$STORAGE_DIR/workspace"
mkdir -p "$STORAGE_DIR/config"

# 获取用户提供的 Token (通过环境变量或硬编码，优先环境变量)
# 注意：在 HF Space 中，建议用户在 Settings -> Secrets 中设置 TG_TOKEN
TOKEN="${TG_TOKEN:-8706533687:AAHQIxNouxWxn2HM2Ita2w7B8_CkKda4nio}"

# 生成 openclaw.json 配置文件
# 使用 mode: local 绕过复杂的云端认证/注册流程
cat > "$CONF_FILE" <<EOF
{
  "gateway": {
    "mode": "local",
    "port": 7860,
    "listen": "0.0.0.0:7860"
  },
  "agents": {
    "defaults": {
      "workspace": "$STORAGE_DIR/workspace"
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

# 同时也复制一份到 /app/storage/config 以备不时之需
cp "$CONF_FILE" "$STORAGE_DIR/config/openclaw.json"

echo "OpenClaw configuration generated at $CONF_FILE"
echo "Starting Gateway on port 7860..."

# 设置环境变量，强制程序识别配置和端口
export PORT=7860
export OPENCLAW_PORT=7860
export OPENCLAW_LISTEN="0.0.0.0:7860"
export OPENCLAW_HOME="$CONF_DIR"

# 启动命令
# 使用 --allow-unconfigured 进一步确保即使配置检查严苛也能启动
# 加上交互式输入模拟（虽然已有配置，但双重保险）
printf "\n\n\n\n\n\n" | node scripts/run-node.mjs gateway --port 7860 --allow-unconfigured
