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

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/701292d6-a4ea-41a3-93b1-e5562587eed6";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/8DD3-7D63";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };

    swapDevices = [];

    nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  };
}
