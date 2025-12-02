## ADDED Requirements

### Requirement: Strip Nix Comments Program
The system SHALL provide a `strip-nix-comments` utility that removes all comments from Nix source files by parsing them with libnix and re-emitting the AST, which naturally excludes comments.

#### Scenario: Line comment removal
- **WHEN** user pipes Nix code containing line comments (`# comment`) to `strip-nix-comments`
- **THEN** the output contains the same Nix expression with all line comments removed

#### Scenario: Block comment removal
- **WHEN** user pipes Nix code containing block comments (`/* comment */`) to `strip-nix-comments`
- **THEN** the output contains the same Nix expression with all block comments removed

#### Scenario: String literal preservation
- **WHEN** user pipes Nix code containing strings with comment-like characters (`"# not a comment"` or `'' /* also not */ ''`)
- **THEN** the string contents are preserved exactly, not treated as comments

#### Scenario: Parse error handling
- **WHEN** user pipes syntactically invalid Nix code to `strip-nix-comments`
- **THEN** the program exits with code 1 and outputs an error message to stderr

#### Scenario: Canonical formatting output
- **WHEN** user pipes valid Nix code to `strip-nix-comments`
- **THEN** the output is valid Nix code in canonical (pretty-printed) format that can be parsed by `nix-instantiate`

#### Scenario: stdin/stdout filter pattern
- **WHEN** user runs `strip-nix-comments` without arguments
- **THEN** the program reads from stdin and writes to stdout, enabling use in shell pipelines

### Requirement: Cross-Platform Availability
The system SHALL provide the `strip-nix-comments` program as a deployable system package on NixOS and macOS (darwin) environments through automatic Denix module discovery.

#### Scenario: NixOS availability
- **WHEN** `strip-nix-comments` module is discovered by Denix
- **THEN** the program is available in `environment.systemPackages` on NixOS hosts

#### Scenario: Darwin availability
- **WHEN** `strip-nix-comments` module is discovered by Denix
- **THEN** the program is available in `environment.systemPackages` on macOS hosts via nix-darwin

### Requirement: Native C++ Implementation with libnix
The system SHALL implement the comment stripper in C++ using the official libnix library to ensure parsing correctness.

#### Scenario: Uses official Nix parser
- **WHEN** `strip-nix-comments` parses input
- **THEN** it uses `nix::EvalState::parseExprFromString()` from libnix, the same parser used by `nix-instantiate`

#### Scenario: AST-based comment removal
- **WHEN** `strip-nix-comments` processes Nix code
- **THEN** comments are removed because the Nix AST does not preserve them, and `Expr::show()` reconstructs only semantic content

#### Scenario: Minimal store initialization
- **WHEN** `strip-nix-comments` initializes libnix
- **THEN** it uses a `dummy://` store to avoid filesystem access, since parsing does not require store operations
