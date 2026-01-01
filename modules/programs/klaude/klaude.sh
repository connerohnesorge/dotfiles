#!/usr/bin/env bash

export ANTHROPIC_BASE_URL=https://api.kimi.com/coding/
export ANTHROPIC_AUTH_TOKEN=$(grep '^KIMI_API_KEY=' ~/dotfiles/.env | cut -d '=' -f 2)
# export ANTHROPIC_SMALL_FAST_MODEL=kimi-for-coding
# export ANTHROPIC_MODEL=kimi-for-coding
# export ANTHROPIC_MODEL=kimi-k2-thinking-turbo
# export ANTHROPIC_SMALL_FAST_MODEL=kimi-k2-thinking-turbo
export ANTHROPIC_SMALL_FAST_MODEL=moonshot-v1-8k-vision-preview
export ANTHROPIC_MODEL=moonshot-v1-8k-vision-preview

claude --dangerously-skip-permissions $@
