{
  delib,
  inputs,
  pkgs,
  config,
  lib,
  ...
}: let
  system = "aarch64-darwin";
in
  delib.host {
    name = "Conners-MacBook-Air";
    rice = "empty";
    type = "laptop";

    home.home.stateVersion = "24.11";
    homeManagerSystem = system;

    myconfig = {
      features = {
        engineer.enable = true;
      };
      programs = {
        dx.enable = true;
        catls.enable = true;
        convert_img.enable = true;
      };
    };

    nixos = {
      imports = [
        inputs.determinate.nixosModules.default
      ];
      nixpkgs.hostPlatform = "x86_64-linux";
      nixpkgs.config.allowUnfree = true;
      nixpkgs.config.allowUnsupportedSystem = true;
      system.stateVersion = "24.11";

      # Minimal file system configuration to prevent assertion failures
      fileSystems."/" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
    };

    darwin = {
      imports = [
        # inputs.determinate.darwinModules.default
      ];

      nixpkgs = {
        hostPlatform = system;
        config.allowUnfree = true;
      };
      nix.enable = false;
      # $ nix-env -qaP | grep wget
      programs = {
        direnv = {
          enable = true;
          nix-direnv = {
            enable = true;
            package = pkgs.nix-direnv;
          };
        };
        ssh = {
          extraConfig = ''
            SetEnv TERM=xterm-256color
          '';
        };
      };
      system = {
        stateVersion = 5;
        primaryUser = "connerohnesorge";
        defaults = {
          dock.autohide = true;

          trackpad = {
            Clicking = true;
            TrackpadThreeFingerDrag = true;
            Dragging = true;
          };
        };
      };

      environment = {
        systemPackages = [
          # Macos Only
          pkgs.aerospace
          pkgs.raycast
          pkgs.xcodes
          # Shared
        ];
        shells = [pkgs.zsh];

        pathsToLink = ["/share/qemu"];
        etc."containers/containers.conf.d/99-gvproxy-path.conf".text = ''
          [engine]
          helper_binaries_dir = ["${pkgs.gvproxy}/bin"]
        '';
      };
      users.users.connerohnesorge = {
        home = "/Users/connerohnesorge";
      };

      security.pam.services.sudo_local.touchIdAuth = true;
    };
  }
