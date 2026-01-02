{
  delib,
  pkgs,
  ...
}: let
  inherit (delib) singleEnableOption;
  program = pkgs.buildGoModule {
    pname = "catls";
    version = "2.0.0";

    src = ./.;

    vendorHash = "sha256-m5mBubfbXXqXKsygF5j7cHEY+bXhAMcXUts5KBKoLzM=";

    meta = with pkgs.lib; {
      description = "Enhanced file listing utility with XML, Markdown, and JSON output";
      homepage = "https://github.com/connerosiu/dotfiles";
      license = licenses.mit;
      maintainers = [];
    };
  };
in
  delib.module {
    name = "programs.catls";

    options = singleEnableOption false;

    nixos.ifEnabled = {
      environment.systemPackages = [
        program
      ];
    };

    darwin.ifEnabled = {
      environment.systemPackages = [
        program
      ];
    };
  }
