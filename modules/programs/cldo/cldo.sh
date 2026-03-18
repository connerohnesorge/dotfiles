#!/usr/bin/env bash

claude --model="opus[1m]" --dangerously-skip-permissions "$@"
