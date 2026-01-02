#!/usr/bin/env bash

PORT=1738 
if ! lsof -iTCP:$PORT -sTCP:LISTEN >/dev/null 2>&1; then
	PORT=1738 bunx antigravity-claude-proxy start > /dev/null 2>&1 &
fi

export ANTHROPIC_AUTH_TOKEN=test
export ANTHROPIC_BASE_URL="http://localhost:$PORT"
export ANTHROPIC_MODEL=claude-opus-4-5-thinking
export ANTHROPIC_DEFAULT_OPUS_MODEL=claude-opus-4-5-thinking
export ANTHROPIC_DEFAULT_SONNET_MODEL=claude-sonnet-4-5-thinking
export ANTHROPIC_DEFAULT_HAIKU_MODEL=claude-sonnet-4-5
export CLAUDE_CODE_SUBAGENT_MODEL=claude-sonnet-4-5-thinking

claude --dangerously-skip-permissions $@
