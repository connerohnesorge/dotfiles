# Design: strip-nix-comments using libnix

## Context

We need a reliable tool to strip comments from Nix files. The Nix language has specific comment syntax:
- Line comments: `# comment`
- Block comments: `/* comment */`

Custom parsers are error-prone due to edge cases (strings containing `#`, nested comments, etc.). The libnix library provides the canonical parser used by Nix itself.

**Stakeholders**: Developers who want to minify/clean Nix configurations

**Constraints**:
- Must link against libnix (C++ library)
- Must handle Nix 2.x API (current nixpkgs version)
- Must work on both Linux and macOS

## Goals / Non-Goals

**Goals**:
- Use official Nix parser for 100% correct parsing
- Simple stdin→stdout filter interface
- Minimal dependencies (only nix library)
- Fast execution (native C++)

**Non-Goals**:
- Preserving formatting/whitespace (AST pretty-print is canonical)
- Supporting other languages (Nix-only)
- In-place file editing (use shell redirection: `strip-nix-comments < file.nix > file.nix.tmp`)
- Preserving specific comments (all comments are stripped)

## Decisions

### Decision 1: Use `parseExprFromString` + `Expr::show()`

**What**: Parse input into AST, then pretty-print it back out.

**Why**:
- The Nix lexer discards comments during tokenization
- AST only contains semantic content
- `show()` produces valid, parseable Nix output
- This is guaranteed correct because it uses the same parser as `nix-instantiate`

**Alternatives considered**:
1. **Regex substitution** - Rejected: Too fragile, can't handle strings containing `#` or `/*`
2. **Custom lexer** - Rejected: Duplicates work already done in libnix, maintenance burden
3. **Tree-sitter parser** - Rejected: Adds external dependency, may drift from official syntax

### Decision 2: Use Nix's `dummy://` store

**What**: Create a dummy store that doesn't actually access the filesystem.

**Why**:
- `EvalState` requires a store reference
- We don't need actual store operations (no evaluation, just parsing)
- `dummy://` is the minimal no-op implementation

```cpp
std::shared_ptr<Store> store = openStore("dummy://");
EvalState state({}, store);
```

### Decision 3: stdin/stdout filter pattern

**What**: Read from stdin, write to stdout, errors to stderr.

**Why**:
- Unix philosophy: do one thing well
- Composable with shell pipelines
- No file permission/ownership concerns
- Simple to test

**Usage patterns**:
```bash
# Preview stripped output
strip-nix-comments < config.nix

# In-place update
strip-nix-comments < file.nix | sponge file.nix

# Process multiple files
for f in *.nix; do strip-nix-comments < "$f" > "$f.tmp" && mv "$f.tmp" "$f"; done
```

### Decision 4: Nix derivation build approach

**What**: Use `stdenv.mkDerivation` with explicit nix library linking.

**Why**:
- `pkgs.nix.dev` provides headers and libraries
- Need to link: `-lnixexpr -lnixstore -lnixutil -lnixmain`
- pkg-config available via `nix.dev`

```nix
stdenv.mkDerivation {
  pname = "strip-nix-comments";
  version = "0.1.0";
  src = ./.;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ nix.dev boost ];

  buildPhase = ''
    $CXX -O2 -std=c++17 \
      $(pkg-config --cflags nix-expr) \
      -o strip-nix-comments main.cpp \
      $(pkg-config --libs nix-expr nix-store nix-main)
  '';
}
```

### Decision 5: Error handling strategy

**What**: Parse errors go to stderr with exit code 1.

**Why**:
- Invalid Nix input should fail loudly
- Exit code enables shell scripting (`set -e`)
- Error messages from libnix are already descriptive

```cpp
try {
    Expr *expr = state.parseExprFromString(input, "stdin");
    expr->show(std::cout);
    return 0;
} catch (Error &e) {
    std::cerr << "Parse error: " << e.what() << "\n";
    return 1;
}
```

## Risks / Trade-offs

| Risk | Impact | Mitigation |
|------|--------|------------|
| libnix API changes between Nix versions | Build failure | Pin to stable nixpkgs, monitor upstream |
| Formatting differs from original | Cosmetic | Document that output is canonical, not preserving |
| Large files cause memory issues | Rare | Document stdin-based approach handles typical configs |
| macOS linker differences | Build failure | Test on Darwin in CI |

## Build Dependencies

### Required packages:
- `nix.dev` - Headers and pkg-config files for libnix
- `boost` - Required by nix internals (header-only parts)
- `pkg-config` - For finding library flags

### Linking:
The nix expression evaluator depends on several libraries:
- `nix-expr` - Expression evaluation, parsing
- `nix-store` - Store abstraction (needed even for dummy store)
- `nix-util` - Utility functions
- `nix-main` - Initialization code

## Implementation Notes

### C++ Standard
Use C++17 for:
- `std::filesystem` (if needed)
- Structured bindings
- `std::optional` / `std::variant`

### Header includes
```cpp
#include <nix/eval.hh>        // EvalState
#include <nix/parser.hh>      // parseExprFromString (via eval.hh)
#include <nix/store-api.hh>   // openStore
#include <nix/shared.hh>      // initNix (if needed)
```

### Initialization sequence
```cpp
// Some nix versions may need explicit init
// nix::initNix();

auto store = nix::openStore("dummy://");
nix::EvalState state({}, store);
```

## Migration Plan

N/A - This is a new program with no existing users to migrate.

## Open Questions

1. **Should we add `--version` / `--help` flags?**
   - Leaning towards no for simplicity, but could add minimal support

2. **Should we handle multiple expressions in one file?**
   - Current approach: parse as single expression (standard Nix file format)
   - If needed: could wrap in `[ ... ]` internally

3. **Should there be a wrapper script for batch processing?**
   - Defer: users can use shell for-loops
   - Could add `strip-nix-comments-dir` later if demand exists
