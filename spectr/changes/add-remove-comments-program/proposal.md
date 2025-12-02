# Change: Add strip-nix-comments program using libnix

## Why

Nix configuration files often accumulate comments that add overhead to file size and can clutter production distributions. By leveraging libnix's built-in parser and AST pretty-printer, we can create a robust comment stripper that:

1. Uses the **official Nix parser** - guaranteeing correct syntax handling
2. Exploits the fact that `Expr::show()` drops comments - the AST simply doesn't preserve them
3. Provides canonical formatting as a side effect

This approach is fundamentally more reliable than regex-based or custom parser solutions because it uses the exact same parser that evaluates Nix expressions.

## What Changes

- Add new custom program module: `modules/programs/strip-nix-comments/`
  - C++ implementation using libnix (`nix/eval.hh`, `nix/parser.hh`)
  - Links against nix libraries for AST parsing
  - Reads from stdin, writes to stdout (Unix filter pattern)
  - Cross-platform deployment (NixOS, Darwin)
  - Simple, focused interface - does one thing well

## Impact

- Affected specs: `custom-programs` (new capability)
- Affected code: `modules/programs/strip-nix-comments/` (new)
- Build dependencies: `pkgs.nix.dev` for libnix headers
- No breaking changes; purely additive
- Available as a system package after flake rebuild

## Technical Approach

The program exploits a fundamental property of libnix:

```cpp
// Parse using the official Nix parser
Expr *expr = state.parseExprFromString(input, "stdin");

// Pretty-print back - comments are gone because AST doesn't preserve them
expr->show(std::cout);
```

This is the canonical way to strip comments from Nix files because:
1. The Nix lexer discards comments during tokenization
2. The AST only contains semantic content
3. `show()` reconstructs valid Nix syntax without comments
