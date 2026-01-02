{
  delib,
  pkgs,
  ...
}: let
  inherit (delib) singleEnableOption;

  program =
    pkgs.writers.writePython3Bin "convert_img" {
      flakeIgnore = ["W291" "W503" "E226" "E501" "W293"];
      libraries = with pkgs.python3Packages; [
        pillow
      ];
    }
    ./convert_img.py;
in
  delib.module {
    name = "programs.convert_img";

    options = singleEnableOption false;

    nixos.ifEnabled = {
      environment.systemPackages = [
        program
        pkgs.potrace
      ];
    };

    darwin.ifEnabled = {
      environment.systemPackages = [
        program
        pkgs.potrace
      ];
    };
  }
