{
  delib,
  pkgs,
  ...
}: let
  inherit (delib) singleEnableOption;

  program = pkgs.writeShellApplication {
    name = "clds";
    text = builtins.readFile ./clds.sh;
  };
in
  delib.module {
    name = "programs.clds";

    options = singleEnableOption false;

    nixos.ifEnabled = {
      environment.systemPackages = [program];
    };

    darwin.ifEnabled = {
      environment.systemPackages = [program];
    };
  }
