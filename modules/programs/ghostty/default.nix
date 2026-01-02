{
  delib,
  pkgs,
  ...
}: let
  inherit (delib) singleEnableOption;
  inherit (pkgs.stdenv) isDarwin isLinux;
in
  delib.module {
    name = "programs.ghostty";

    options = singleEnableOption false;

    home.ifEnabled = {
      # Deploy platform-specific configuration file via Home Manager
      # The configuration will be symlinked to ~/.config/ghostty/config
      xdg.configFile."ghostty/config" = {
        source =
          if isLinux
          then ../../../.config/ghostty/ghostty.linux
          else if isDarwin
          then ../../../.config/ghostty/ghostty.macos
          else ../../../.config/ghostty/ghostty.linux; # Default to Linux config for other platforms
      };
      # Alternative: Use XDG config to ensure directory
      xdg.configFile."dconf/.keep" = {
        text = "";
        force = true;
      };
    };

    # Deploy configuration at system level for NixOS
    nixos.ifEnabled = {myconfig, ...}: let
      # Get username from the constants module for consistency
      inherit (myconfig.constants) username;

      # Select the appropriate config file based on platform
      ghosttyConfigFile = ../../../.config/ghostty/ghostty.linux;
    in {
      # Create symlink in user's home directory via activation script
      # This ensures the config is properly linked after each rebuild
      system.activationScripts.ghosttyConfig = {
        text = ''
          # Ensure the target directory exists with proper ownership
          TARGET_DIR="/home/${username}/.config/ghostty"
          if [[ ! -d "$TARGET_DIR" ]]; then
            mkdir -p "$TARGET_DIR"
            chown "${username}:users" "$TARGET_DIR"
          fi

          # Create or update the config symlink
          # Using -f to force update if it already exists
          CONFIG_LINK="$TARGET_DIR/config"
          CONFIG_SOURCE="${ghosttyConfigFile}"

          if ln -sf "$CONFIG_SOURCE" "$CONFIG_LINK"; then
            chown -h "${username}:users" "$CONFIG_LINK"
          else
            echo "Warning: Failed to create Ghostty config symlink at $CONFIG_LINK" >&2
          fi
        '';
        deps = [];
      };
    };
  }
