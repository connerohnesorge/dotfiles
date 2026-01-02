{
  delib,
  pkgs,
  ...
}: let
  inherit (delib) singleEnableOption;

  program = pkgs.stdenv.mkDerivation {
    name = "cf";
    src = ./.;

    nativeBuildInputs = with pkgs; [
      makeWrapper
      fzf
      fd
      coreutils
    ];

    installPhase = ''
      mkdir -p $out/bin
      cp cf $out/bin/
      chmod +x $out/bin/cf

      wrapProgram $out/bin/cf \
        --prefix PATH : ${pkgs.lib.makeBinPath [
        pkgs.fzf
        pkgs.fd
        pkgs.coreutils
      ]}
    '';
  };
in
  delib.module {
    name = "programs.cf";

    options = singleEnableOption false;

    nixos.ifEnabled = {
      environment.systemPackages = [program];
    };

    darwin.ifEnabled = {
      environment.systemPackages = [program];
    };
  }
