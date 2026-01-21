{
  delib,
  lib,
  modulesPath,
  config,
  inputs,
  ...
}:
delib.host {
  name = "nixos";

  homeManagerSystem = "aarch64-linux";
  home.home.stateVersion = "25.11";

  nixos = {
    system.stateVersion = "25.11";
    imports = [
      (modulesPath + "/profiles/qemu-guest.nix")
    ];

    boot.initrd.availableKernelModules = ["xhci_pci" "virtio_pci" "usbhid" "usb_storage" "sr_mod"];
    boot.initrd.kernelModules = [];
    boot.kernelModules = [];
    boot.extraModulePackages = [];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/1775d191-55b1-4b21-9b2f-ac22e9e3529f";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/7A1C-B2BD";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

    swapDevices = [];

    nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  };
}
