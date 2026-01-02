{
  description = "A development shell for TypeScript";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = {
    nixpkgs,
    flake-utils,
    treefmt-nix,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      rooted = exec:
        builtins.concatStringsSep "\n"
        [
          ''REPO_ROOT="$(git rev-parse --show-toplevel)"''
          exec
        ];

      scripts = {
        dx = {
          exec = rooted ''$EDITOR "$REPO_ROOT"/flake.nix'';
          description = "Edit flake.nix";
          deps = [pkgs.git];
        };
        tx = {
          exec = rooted ''$EDITOR "$REPO_ROOT"/tsconfig.json'';
          description = "Edit tsconfig.json";
        };
        px = {
          exec = rooted ''$EDITOR "$REPO_ROOT"/package.json'';
          description = "Edit package.json";
        };
      };

      scriptPackages =
        pkgs.lib.mapAttrs
        (
          name: script:
            pkgs.writeShellApplication {
              inherit name;
              text = script.exec;
              runtimeInputs = script.deps or [];
            }
        )
        scripts;
    in {
      devShells.default = pkgs.mkShell {
        name = "typescript-dev";

        # Available packages on https://search.nixos.org/packages
        packages = with pkgs;
          [
            # Nix tooling
            alejandra
            nixd
            statix
            deadnix

            # TypeScript core
            typescript
            nodejs
            tsx # Fast TypeScript execution

            # Package managers
            bun

            # Linters and formatters
            eslint
            oxlint
            biome
            nodePackages.prettier

            # Language servers
            typescript-language-server
            tailwindcss-language-server
            vscode-langservers-extracted # HTML, CSS, JSON, ESLint LSPs
            yaml-language-server

            # CSS and styling
            tailwindcss
            nodePackages.autoprefixer

            # Utility tools
            jq # JSON processing
            nodePackages.concurrently # Run multiple commands
            nodePackages.nodemon # File watching
          ]
          ++ builtins.attrValues scriptPackages;

        shellHook = ''
          echo "Available commands:"
          ${pkgs.lib.concatStringsSep "\n" (
            pkgs.lib.mapAttrsToList (name: script: ''echo "  ${name} - ${script.description}"'') scripts
          )}
        '';
      };

      packages = {
        # Example TypeScript package build (uncomment and customize)
        # default = pkgs.buildNpmPackage {
        #   pname = "my-typescript-project";
        #   version = "0.1.0";
        #   src = ./.;
        #   npmDepsHash = ""; # Run nix build to get the correct hash
        #   buildPhase = ''
        #     npm run build
        #   '';
        #   installPhase = ''
        #     mkdir -p $out
        #     cp -r dist/* $out/
        #   '';
        #   meta = with pkgs.lib; {
        #     description = "My TypeScript project";
        #     homepage = "https://github.com/user/my-typescript-project";
        #     license = licenses.mit;
        #     maintainers = with maintainers; [ ];
        #   };
        # };
      };

      formatter = let
        treefmtModule = {
          projectRootFile = "flake.nix";
          programs = {
            alejandra.enable = true; # Nix formatter
            prettier.enable = true; # JavaScript/TypeScript formatter
          };
        };
      in
        treefmt-nix.lib.mkWrapper pkgs treefmtModule;
    });
}
