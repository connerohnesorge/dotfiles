{
  delib,
  inputs,
  ...
}:
delib.host {
  name = "oxe-nixos";

  rice = "dark";
  type = "server";
  home.home.stateVersion = "24.11";

  darwin = {
    imports = [
      inputs.determinate.darwinModules.default
    ];
    nixpkgs.hostPlatform = "x86_64-darwin";
    system.stateVersion = "24.11";
  };

  nixos = {
    nixpkgs.config.allowUnfree = true;
    imports = [
      inputs.determinate.nixosModules.default
      ./hardware.nix
    ];

    myconfig = {
      features = {
        amd.enable = true;
        hyprland.enable = true;
        engineer.enable = true;
        darknet.enable = true;
        secrets.enable = true;
        ollama.enable = true;
      };
    };

    boot = {
      plymouth.enable = true;
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
        systemd-boot.configurationLimit = 4;
      };
    };

    security = {
      rtkit.enable = true;
      pam.services.login.enableGnomeKeyring = true;
    };
    virtualisation.docker.enable = true;

    services = {
      openssh = {
        enable = true;
        passwordAuthentication = false;
      };
    };

    time.timeZone = "America/Chicago";
    i18n = {
      # Select internationalisation properties.
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = "en_US.UTF-8";
        LC_IDENTIFICATION = "en_US.UTF-8";
        LC_MEASUREMENT = "en_US.UTF-8";
        LC_MONETARY = "en_US.UTF-8";
        LC_NAME = "en_US.UTF-8";
        LC_NUMERIC = "en_US.UTF-8";
        LC_PAPER = "en_US.UTF-8";
        LC_TELEPHONE = "en_US.UTF-8";
        LC_TIME = "en_US.UTF-8";
      };
    };
  };
}
