/**
Google Claude (local)
*/
{
  delib,
  pkgs,
  ...
}: let
  inherit (delib) singleEnableOption;

  program = pkgs.writeShellApplication {
    name = "glaude";
    text = builtins.readFile ./glaude.sh;
    excludeShellChecks = [
      "SC2068"
      "SC2155"
    ];
  };
in
  delib.module {
    name = "programs.glaude";

    options = singleEnableOption false;

    nixos.ifEnabled = {
      environment.systemPackages = [program];
    };

    darwin.ifEnabled = {
      environment.systemPackages = [program];
    };
  }
