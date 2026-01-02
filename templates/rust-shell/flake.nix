{
  description = "A development shell for rust";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
    crane.url = "github:ipetkov/crane";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    rust-overlay,
    crane,
    treefmt-nix,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [rust-overlay.overlays.default];
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
        };
        rx = {
          exec = rooted ''$EDITOR "$REPO_ROOT"/Cargo.toml'';
          description = "Edit Cargo.toml";
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
      # Optional: Initialize crane for building packages
      # craneLib = (crane.mkLib pkgs).overrideToolchain (p: p.rust-bin.stable.latest.default);
      # Optional: Example crane package build (uncomment to use)
      # my-crate = craneLib.buildPackage {
      #   src = craneLib.cleanCargoSource ./.;
      #   strictDeps = true;
      # };
    in {
      # Optional: Define packages if using crane to build (uncomment to use)
      # packages = forAllSystems (system: let
      #   pkgs = import nixpkgs {
      #     inherit system;
      #     overlays = [rust-overlay.overlays.default];
      #   };
      #   craneLib = (crane.mkLib pkgs).overrideToolchain (p: p.rust-bin.stable.latest.default);
      # in {
      #   default = craneLib.buildPackage {
      #     src = craneLib.cleanCargoSource ./.;
      #     strictDeps = true;
      #   };
      # });

      devShells.default = pkgs.mkShell {
        name = "dev";
        # Available packages on https://search.nixos.org/packages
        buildInputs = with pkgs;
          [
            alejandra # Nix
            nixd
            statix
            deadnix
            just
            rust-bin.stable.latest.default
            rust-bin.stable.latest.rust-analyzer
          ]
          ++ builtins.attrValues scriptPackages;
        shellHook = ''
          echo "Welcome to the rust devshell!"
        '';
      };

      formatter = let
        treefmtModule = {
          projectRootFile = "flake.nix";
          programs = {
            alejandra.enable = true; # Nix formatter
            rustfmt.enable = true; # Rust formatter
          };
        };
      in
        treefmt-nix.lib.mkWrapper pkgs treefmtModule;
    });
}
