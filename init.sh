#!/bin/bash
# Telegram API 反向代理补丁
# 在 OpenClaw 启动前执行，将所有 api.telegram.org 替换为反向代理地址
# 解决 Hugging Face 网络限制导致无法直连 Telegram API 的问题

set -e

TG_PROXY_DOMAIN="tgproxy.liblaf.top/bot"

echo "[init] Patching Telegram API endpoint → $TG_PROXY_DOMAIN"

# 定向补丁 OpenClaw 编译产物（/opt/openclaw/app/dist）
if [ -d "/opt/openclaw/app/dist" ]; then
    find /opt/openclaw/app/dist -type f -name "*.js" -exec \
        sed -i "s|api.telegram.org|$TG_PROXY_DOMAIN|g" {} + 2>/dev/null || true
    echo "[init] Patched /opt/openclaw/app/dist"
fi

# 定向补丁 Telegraf 库
if [ -d "/opt/openclaw/app/node_modules/telegraf" ]; then
    find /opt/openclaw/app/node_modules/telegraf -type f -name "*.js" -exec \
        sed -i "s|api.telegram.org|$TG_PROXY_DOMAIN|g" {} + 2>/dev/null || true
    echo "[init] Patched telegraf module"
fi

# 定向补丁 node-telegram-bot-api 库
if [ -d "/opt/openclaw/app/node_modules/node-telegram-bot-api" ]; then
    find /opt/openclaw/app/node_modules/node-telegram-bot-api -type f -name "*.js" -exec \
        sed -i "s|api.telegram.org|$TG_PROXY_DOMAIN|g" {} + 2>/dev/null || true
    echo "[init] Patched node-telegram-bot-api module"
fi

echo "[init] Telegram API patch complete!"
