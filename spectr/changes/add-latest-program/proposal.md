# Change: Add `latest` program to replace shell alias

## Why
The current `latest` alias in `.zshrc` (`git add . && git commit -m "latest" && git push`) creates uninformative commit messages. Replacing it with a program that invokes `cldk` to generate AI-assisted commit messages will produce more meaningful git history.

## What Changes
- Create new program module `modules/programs/latest/` that calls `cldk "commit and push all changes with good commit messages"`
- Remove `latest` alias from `.zshrc`
- Enable the `latest` program in the engineer feature module for both NixOS and Darwin

## Impact
- Affected specs: `shell-utilities`
- Affected code:
  - `modules/programs/latest/` (new)
  - `modules/features/engineer.nix` (add `latest.enable = true`)
  - `.zshrc` (remove alias)
