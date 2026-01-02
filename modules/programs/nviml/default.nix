{
  delib,
  pkgs,
  ...
}: let
  inherit (delib) singleEnableOption;

  program = pkgs.stdenv.mkDerivation {
    name = "nviml";
    src = ./.;

    nativeBuildInputs = with pkgs; [
      makeWrapper
      ripgrep
      fzf
      bat
    ];

    installPhase = ''
      mkdir -p $out/bin
      cp nviml $out/bin/
      chmod +x $out/bin/nviml

      wrapProgram $out/bin/nviml \
        --prefix PATH : ${pkgs.lib.makeBinPath [pkgs.ripgrep pkgs.fzf pkgs.bat]}
    '';
  };
in
  delib.module {
    name = "programs.nviml";

    options = singleEnableOption false;

    nixos.ifEnabled = {
      environment.systemPackages = [program];
    };

    darwin.ifEnabled = {
      environment.systemPackages = [program];
    };
  }
