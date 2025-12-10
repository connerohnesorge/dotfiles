## ADDED Requirements

### Requirement: Latest Program
The system SHALL provide a `latest` program that commits and pushes all changes with AI-generated commit messages using the `cldk` tool.

#### Scenario: User runs latest in git repository
- **WHEN** user executes `latest` in a git repository with uncommitted changes
- **THEN** the program invokes `cldk "commit and push all changes with good commit messages"` to stage, commit, and push changes with meaningful AI-generated messages

#### Scenario: Cross-platform availability
- **WHEN** the engineer feature is enabled on NixOS or Darwin
- **THEN** the `latest` program is available in the system PATH

#### Scenario: Replaces shell alias
- **WHEN** user previously used the `latest` alias in `.zshrc`
- **THEN** the `latest` program provides the same entry point with improved commit message quality
