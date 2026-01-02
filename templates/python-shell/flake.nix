{
  description = "A development shell for Python";

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
        name = "python-dev";

        # Available packages on https://search.nixos.org/packages
        packages = with pkgs;
          [
            # Nix tooling
            alejandra
            nixd
            statix
            deadnix

            # Python interpreter and package managers
            uv # Best

            # Type checking and linting
            pyrefly # Advanced type checker (Pylance)
            mypy # Static type checker
            ruff # Fast Python linter and formatter
            black # Code formatter
            isort # Import sorter

            # Development utilities
            git
            curl
            jq
          ]
          ++ builtins.attrValues scriptPackages;

        shellHook = ''
          # Set up Python environment
          export PYTHONPATH="$PWD/src:$PYTHONPATH"
          export PYTHONDONTWRITEBYTECODE=1
          export PYTHONUNBUFFERED=1
        '';
      };

      packages = {
        # Example Python package build (uncomment and customize)
        # default = pkgs.python312Packages.buildPythonApplication {
        #   pname = "my-python-app";
        #   version = "0.1.0";
        #   src = ./.;
        #   propagatedBuildInputs = with pkgs.python312Packages; [
        #     requests
        #     click
        #   ];
        #   checkInputs = with pkgs.python312Packages; [
        #     pytest
        #     pytest-cov
        #   ];
        #   checkPhase = ''
        #     pytest
        #   '';
        #   meta = with pkgs.lib; {
        #     description = "My Python application";
        #     homepage = "https://github.com/user/my-python-app";
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
            black.enable = true; # Python formatter
            ruff-format.enable = true; # Python linter/formatter
          };
        };
      in
        treefmt-nix.lib.mkWrapper pkgs treefmtModule;
    });
}
