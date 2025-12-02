# Tasks: strip-nix-comments Implementation

## 1. Create Program Directory and Derivation

- [ ] 1.1 Create `modules/programs/strip-nix-comments/` directory
- [ ] 1.2 Create `default.nix` with Nix derivation using `stdenv.mkDerivation`
- [ ] 1.3 Configure `buildInputs` with `nix.dev` and `boost`
- [ ] 1.4 Configure `nativeBuildInputs` with `pkg-config`
- [ ] 1.5 Set up pkg-config invocation for libnix linking (`-lnixexpr -lnixstore -lnixutil -lnixmain`)

## 2. Implement C++ Source

- [ ] 2.1 Create `main.cpp` with libnix includes:
  ```cpp
  #include <nix/eval.hh>
  #include <nix/store-api.hh>
  ```
- [ ] 2.2 Implement stdin reading using `std::stringstream` buffer
- [ ] 2.3 Create dummy store with `openStore("dummy://")`
- [ ] 2.4 Initialize `EvalState` with empty search path
- [ ] 2.5 Parse input with `state.parseExprFromString(input, "stdin")`
- [ ] 2.6 Output result with `expr->show(std::cout)`
- [ ] 2.7 Implement try/catch for `nix::Error` with stderr output and exit code 1

## 3. Nix Module Integration

- [ ] 3.1 Create delib module wrapper following cmbd/catls patterns
- [ ] 3.2 Define `singleEnableOption false` for optional enablement
- [ ] 3.3 Add to `nixos.ifEnabled.environment.systemPackages`
- [ ] 3.4 Add to `darwin.ifEnabled.environment.systemPackages`
- [ ] 3.5 Verify module follows Denix naming: `programs.strip-nix-comments`

## 4. Build and Platform Testing

- [ ] 4.1 Test build on NixOS: `cd modules/programs/strip-nix-comments && nix build`
- [ ] 4.2 Verify linking succeeds (no undefined symbols)
- [ ] 4.3 Test basic execution: `echo '{ x = 1; /* comment */ }' | ./result/bin/strip-nix-comments`
- [ ] 4.4 Test Darwin build compatibility (if Darwin host available)
- [ ] 4.5 Verify pkg-config finds correct nix library version

## 5. Functional Testing

- [ ] 5.1 Test line comment removal: `{ x = 1; # comment }`
- [ ] 5.2 Test block comment removal: `{ x = 1; /* block */ }`
- [ ] 5.3 Test nested/complex comments: `/* outer /* inner */ still comment */`
- [ ] 5.4 Test string preservation: `{ x = "# not a comment"; }`
- [ ] 5.5 Test multiline string preservation: `{ x = '' # also not a comment ''; }`
- [ ] 5.6 Test parse error handling: invalid syntax should exit 1 with message
- [ ] 5.7 Test empty input handling
- [ ] 5.8 Test large file handling (typical flake.nix size)

## 6. Integration Testing

- [ ] 6.1 Process real nix file from this repo: `strip-nix-comments < flake.nix`
- [ ] 6.2 Verify output parses correctly: `strip-nix-comments < flake.nix | nix-instantiate --parse -`
- [ ] 6.3 Test pipeline usage: `cat file.nix | strip-nix-comments | wc -l`
- [ ] 6.4 Test with modules that have extensive comments

## 7. Validation and Finalization

- [ ] 7.1 Run `nix develop -c lint` for static analysis
- [ ] 7.2 Run `nix fmt` to format nix files
- [ ] 7.3 Verify module is discovered by flake auto-discovery
- [ ] 7.4 Test full system rebuild with module enabled
- [ ] 7.5 Confirm program appears in PATH after activation
