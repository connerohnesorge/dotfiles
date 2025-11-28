{
  delib,
  pkgs,
  ...
}: let
  inherit (delib) singleEnableOption;

  program = pkgs.writeShellScriptBin "pull-jj" ''
    jj git fetch
    jj rebase -d main
  '';
in
  delib.module {
    name = "programs.pull-jj";

    options = singleEnableOption false;

    nixos.ifEnabled = {myconfig, ...}: {
      environment.systemPackages = [
        program
      ];
    };

    darwin.ifEnabled = {myconfig, ...}: {
      environment.systemPackages = [
        program
      ];
    };
  }
