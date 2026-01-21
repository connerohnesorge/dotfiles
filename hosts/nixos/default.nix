{
  delib,
  inputs,
  ...
}:
delib.host {
  name = "nixos";

  rice = "empty";
  type = "laptop";
  home.home.stateVersion = "25.11";

  # This is just here to make the denix host module happy.
  # It evaluates each hosts: darwin, nixos, ... TODO: Improve comment.
  darwin = {
    imports = [
      # inputs.determinate.darwinModules.default
    ];
    nixpkgs.hostPlatform = "aarch64-linux";
    system.stateVersion = "25.11";
  };

  nixos = {
    imports = [
      # inputs.determinate.nixosModules.default
    ];

    myconfig = {
      features = {
        hyprland.enable = true;
        engineer.enable = true;
      };
      programs = {};
    };

    nixpkgs.config.allowUnfree = true;
    nixpkgs.hostPlatform = "aarch64-linux";

    boot = {
      plymouth.enable = true;
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
        systemd-boot.configurationLimit = 4;
      };
    };

    networking = {
      hostName = "nixos";
      networkmanager.enable = true;
    };

    hardware = {
      enableAllFirmware = true;
    };

    security = {
      rtkit.enable = true;
      pam.services.login.enableGnomeKeyring = true;
    };

    services = {
      ## Devices
      printing.enable = true;
      libinput.enable = true;
      gnome.gnome-keyring.enable = true;
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
