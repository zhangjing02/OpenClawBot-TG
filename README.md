---
title: OpenClawBot-TG
emoji: 🤖
colorFrom: blue
colorTo: purple
sdk: docker
pinned: false
app_port: 7860
---

# OpenClaw Telegram Bot on Hugging Face

此仓库用于在 Hugging Face Space 上部署 [OpenClaw](https://github.com/openclaw/openclaw) 个人 AI 助手。

## 部署说明

1.  在 Hugging Face 创建一个新的 **Docker Space**。
2.  将此仓库的代码同步到 Space 或手动上传 `Dockerfile` 和 `start.sh`。
3.  在 Space 的 **Settings -> Variables and Secrets** 中添加以下内容：
    -   `OPENCLAW_TELEGRAM_BOT_TOKEN`: 你的 Telegram Bot Token。
    -   `OPENCLAW_MODEL_PROVIDER`: 使用的模型提供商 (如 `openai`, `anthropic`, `google` 等)。
    -   `OPENCLAW_MODEL_API_KEY`: 对应模型的 API Key。
4.  等待构建完成后，你的机器人将上线。

## 注意事项

-   由于 Hugging Face 免费 Space 的重启机制，本地存储的文件（如对话记忆）可能会在重启后丢失。建议配合外部持久化方案使用。
