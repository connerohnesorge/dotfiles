{
  delib,
  pkgs,
  ...
}: let
  inherit (delib) singleEnableOption;

  program = pkgs.stdenv.mkDerivation {
    name = "nvimf";
    src = ./.;

    nativeBuildInputs = with pkgs; [
      makeWrapper
      fzf
      bat
      neovim
      fd
    ];

    installPhase = ''
      mkdir -p $out/bin
      cp nvimf $out/bin/
      chmod +x $out/bin/nvimf

      wrapProgram $out/bin/nvimf \
        --prefix PATH : ${pkgs.lib.makeBinPath [
        pkgs.fzf
        pkgs.bat
        pkgs.neovim
        pkgs.fd
      ]}
    '';
  };
in
  delib.module {
    name = "programs.nvimf";

    options = singleEnableOption false;

    nixos.ifEnabled = {
      environment.systemPackages = [program];
    };

    darwin.ifEnabled = {
      environment.systemPackages = [program];
    };
  }
