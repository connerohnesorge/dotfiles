/**
# Program Module: cf (Change Directory Fuzzy)

## Description
A lightweight interactive fuzzy directory navigator that provides instant directory
selection with preview. Changes to selected directories with a streamlined, efficient
workflow.

## Platform Support
- ✅ NixOS
- ✅ Darwin

## Features
### Core Functionality
- **Fuzzy Directory Finding**: Fast directory search with instant filtering
- **Directory Preview**: Shows directory contents with ls integration
- **Direct Navigation**: Changes to directories immediately upon selection
- **Smart Filtering**: Automatically excludes .git directories
- **Graceful Cancellation**: Clean exit without side effects

### User Experience
- **Interactive Interface**: Clean fzf-based directory selection
- **Colorized Preview**: Directory contents preview for better context
- **Help System**: Built-in help with `cf --help`
- **Error Handling**: Comprehensive validation and error messages
- **Directory Support**: Works in current or specified directory

## Implementation
- **Language**: Bash (with strict error handling)
- **Source**: ./cf (executable shell script)
- **Type**: Interactive command-line utility
- **Dependencies**: fzf, fd, coreutils
- **Build**: stdenv.mkDerivation with makeWrapper

## Architecture
### Script Structure
- Clean function-based design
- Strict error handling with `set -euo pipefail`
- Dependency validation before execution
- Uses fd for fast directory discovery
- Graceful handling of empty selections

### Integration Method
- Uses `makeWrapper` to bundle dependencies into PATH
- Self-contained executable with all tools available
- No runtime dependency resolution needed
- Works independently of system package management

## Usage Examples
### Basic Usage
```bash
cf                         # Open directory picker in current directory
cf ~/projects              # Open directory picker in specific directory
cf --help                 # Show help information
```

### Workflow Integration
```bash
# Quick navigation
cf                         # Select and cd to any directory

# Project navigation
cd ~/myproject && cf       # Browse and navigate to subdirectories

# Multi-directory workflow
cf ~/configs               # Navigate config directories
cf ~/projects              # Navigate project directories
```

## Interactive Features
### Key Bindings (in fzf)
- **Enter**: Change to selected directory
- **Ctrl-C / ESC**: Exit without changing directory
- **Up/Down**: Navigate through directory list
- **Ctrl-/**: Toggle preview window visibility
- **Ctrl-U/D**: Scroll preview window up/down
- **Type to filter**: Fuzzy search directory names

### Visual Elements
- **Header Bar**: Shows key bindings and current operation
- **Preview Window**: Directory contents (60% of screen)
- **Border Styling**: Clean borders for visual clarity
- **Prompt**: Clear indication of current action
- **Reverse Layout**: Results above prompt for better UX

## How It Works
### Selection Pipeline
1. **Validation**: Check dependencies and validate directory
2. **Directory Discovery**: Scan directory tree with fd
3. **Interactive Selection**: Present directories in fzf with preview
4. **Directory Change**: Output selected directory path

### Smart Defaults
- **Directory Filtering**: Excludes .git/ directories
- **Preview**: Shows directory contents with ls --color
- **Graceful Exit**: Returns exit code 0 on cancellation
- **Hidden Support**: Shows hidden directories (except .git)

## Common Use Cases
### Development Workflows
- **Quick Navigation**: Rapidly navigate to any directory in a project
- **Project Exploration**: Browse unfamiliar directory structures efficiently
- **Context Switching**: Jump between different parts of a codebase quickly

### Daily Operations
- **Directory Browsing**: Explore file system hierarchies
- **Configuration Navigation**: Navigate dotfiles and config directories
- **Project Management**: Navigate between different projects
- **Script Integration**: Use in shell scripts for directory selection

## Configuration & Integration
### Module Enablement
```nix
# Direct enablement
myconfig.programs.cf.enable = true;

# Automatic with engineer feature
myconfig.features.engineer.enable = true;  # includes cf
```

### Shell Integration
Since cf outputs a directory path, it needs to be wrapped in a shell function:

```bash
# Add to .zshrc or .bashrc
cf() {
    local dir
    dir=$(/path/to/cf "$@")
    if [ -n "$dir" ]; then
        cd "$dir"
    fi
}
```

Note: The Nix module installs the binary, but shell integration requires
the wrapper function to actually change directories in the current shell.

## Performance & Optimization
### Directory Discovery
- **Fast Scanning**: Uses fd for parallel directory scanning
- **Smart Exclusions**: Skips .git directories
- **No Hidden Cost**: Efficient hidden directory handling

### UI Responsiveness
- **Instant Preview**: Real-time preview as you navigate
- **Smooth Navigation**: Optimized fzf configuration
- **Fast Filtering**: Fuzzy search without lag

## Dependencies & Requirements
### Required Tools
- **fzf**: Command-line fuzzy finder for directory selection
- **fd**: Fast directory finder
- **coreutils**: Standard Unix utilities (ls, cd)

## Error Handling & Troubleshooting
### Common Scenarios
- **No Directory Selected**: Exits gracefully with informative message
- **Invalid Directory**: Clear error message with directory path
- **Missing Dependencies**: Validates all tools before execution
- **Permission Errors**: Readable error messages for access issues

### Debug Information
- **Dependency Check**: Validates fzf, fd, ls before running
- **Path Validation**: Ensures directory exists and is accessible
- **Clear Messages**: All errors include context and suggestions
- **Exit Codes**: Proper exit codes for script integration

## Security Considerations
- **Path Safety**: Validates directory existence before access
- **Permission Respect**: Honors file system permissions
- **No Execution**: Only navigates, doesn't execute files
- **User Control**: Requires explicit directory selection

## Tips & Best Practices
### Effective Usage
- Use in project root directories for quick subdirectory access
- Create shell aliases for frequently accessed directory trees
- Leverage preview to verify directory contents before changing
- Combine with other navigation tools for optimal workflow

### Integration Ideas
- Add shell function wrapper for actual directory changing
- Use in shell scripts for interactive directory selection
- Integrate with tmux for pane-based navigation
- Combine with other CLI tools in custom scripts

## Comparison with Alternatives
### vs. cd with tab completion
- **Faster**: No manual path typing or sequential tab completion
- **Preview**: See directory contents before changing
- **Fuzzy**: Find directories without exact names

### vs. z/autojump
- **Complementary**: cf for exploration, z for frecency-based navigation
- **Visual**: See directory structure while navigating
- **No History Needed**: Works immediately without building database

### vs. ranger/lf
- **Simpler**: Focused on single task (directory navigation)
- **Faster**: Minimal overhead, quick startup
- **Integration**: Easy to use in shell scripts

## Related Tools
- **nvimf**: Fuzzy file finder with Neovim integration
- **fzf**: Underlying fuzzy finder technology
- **fd**: Fast directory discovery
*/
{
  delib,
  pkgs,
  ...
}: let
  inherit (delib) singleEnableOption;

  program = pkgs.stdenv.mkDerivation {
    name = "cf";
    src = ./.;

    nativeBuildInputs = with pkgs; [
      makeWrapper
      fzf
      fd
      coreutils
    ];

    installPhase = ''
      mkdir -p $out/bin
      cp cf $out/bin/
      chmod +x $out/bin/cf

      wrapProgram $out/bin/cf \
        --prefix PATH : ${pkgs.lib.makeBinPath [
        pkgs.fzf
        pkgs.fd
        pkgs.coreutils
      ]}
    '';
  };
in
  delib.module {
    name = "programs.cf";

    options = singleEnableOption false;

    nixos.ifEnabled = {
      environment.systemPackages = [program];
    };

    darwin.ifEnabled = {
      environment.systemPackages = [program];
    };
  }
