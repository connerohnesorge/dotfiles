## ADDED Requirements

### Requirement: Claude Opus Shortcut (cldo)
The system SHALL provide a `cldo` command that launches Claude Code with the Opus model.

#### Scenario: Launch Claude with Opus model
- **WHEN** user runs `cldo`
- **THEN** Claude Code launches with `--model=opus --dangerously-skip-permissions` flags

### Requirement: Claude Sonnet Shortcut (clds)
The system SHALL provide a `clds` command that launches Claude Code with the Sonnet model.

#### Scenario: Launch Claude with Sonnet model
- **WHEN** user runs `clds`
- **THEN** Claude Code launches with `--model=sonnet --dangerously-skip-permissions` flags

### Requirement: Claude Haiku Shortcut (cldk)
The system SHALL provide a `cldk` command that launches Claude Code with the Haiku model.

#### Scenario: Launch Claude with Haiku model
- **WHEN** user runs `cldk`
- **THEN** Claude Code launches with `--model=haiku --dangerously-skip-permissions` flags

### Requirement: Cross-Platform Availability
All Claude model shortcut commands SHALL be available on both NixOS and macOS (Darwin) systems.

#### Scenario: Available on NixOS
- **WHEN** user is on a NixOS system with the feature enabled
- **THEN** cldo, clds, and cldk commands are available in the system PATH

#### Scenario: Available on macOS
- **WHEN** user is on a macOS system with the feature enabled
- **THEN** cldo, clds, and cldk commands are available in the system PATH
