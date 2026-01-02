{
  delib,
  pkgs,
  ...
}: let
  inherit (delib) singleEnableOption;
in
  delib.module {
    name = "features.ollama";

    options = singleEnableOption false;

    nixos.ifEnabled = {myconfig, ...}: {
      environment.systemPackages = with pkgs; [
        ollama
      ];

      services = {
        ollama = {
          enable = true;
          loadModels = ["gpt-oss:20b"];
          package =
            if myconfig.features.amd.enable
            then pkgs.ollama-rocm
            else if myconfig.features.nvidia.enable
            then pkgs.ollama-cuda
            else pkgs.ollama-cpu;
        };
      };
    };
  }
