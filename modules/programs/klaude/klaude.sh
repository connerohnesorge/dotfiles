#!/usr/bin/env bash

export ANTHROPIC_BASE_URL=https://api.kimi.com/coding/
export ANTHROPIC_AUTH_TOKEN=$(grep '^KIMI_API_KEY=' ~/dotfiles/.env | cut -d '=' -f 2)
# export ANTHROPIC_SMALL_FAST_MODEL=kimi-for-coding
# export ANTHROPIC_MODEL=kimi-for-coding
export ANTHROPIC_MODEL=kimi-k2.5
export ANTHROPIC_SMALL_FAST_MODEL=kimi-k2.5
export ANTHROPIC_DEFAULT_OPUS_MODEL=kimi-k2.5

export ANTHROPIC_DEFAULT_SONNET_MODEL=kimi-k2.5
export ANTHROPIC_DEFAULT_HAIKU_MODEL=kimi-k2.5
export CLAUDE_CODE_SUBAGENT_MODEL=kimi-k2.5

claude --dangerously-skip-permissions $@
