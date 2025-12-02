# Change: Add Claude model shortcut programs (cldo, clds, cldk)

## Why
Users need quick shortcuts to launch Claude Code with specific models (Opus, Sonnet, Haiku) without manually typing the full command with flags each time.

## What Changes
- Add `cldo` program: launches Claude with `--model=opus --dangerously-skip-permissions`
- Add `clds` program: launches Claude with `--model=sonnet --dangerously-skip-permissions`
- Add `cldk` program: launches Claude with `--model=haiku --dangerously-skip-permissions`

## Impact
- Affected specs: claude-model-shortcuts (new capability)
- Affected code: `modules/programs/cldo/`, `modules/programs/clds/`, `modules/programs/cldk/` (new directories)
