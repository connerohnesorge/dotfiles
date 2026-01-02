{
  description = "A development shell for zig";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    zig-overlay.url = "github:mitchellh/zig-overlay";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    zls = {
      url = "github:zigtools/zls";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.zig-overlay.follows = "zig-overlay";
    };
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    treefmt-nix,
    zig-overlay,
    zls,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          zig-overlay.overlays.default
          (final: prev: {
            # Add your overlays here
            # Example:
            # my-overlay = final: prev: {
            #   my-package = prev.callPackage ./my-package { };
            # };
          })
        ];
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
        zx = {
          exec = rooted ''$EDITOR "$REPO_ROOT"/build.zig'';
          description = "Edit build.zig";
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

      treefmtModule = {
        projectRootFile = "flake.nix";
        programs = {
          alejandra.enable = true; # Nix formatter
          zig.enable = pkgs.stdenv.isLinux; # Zig formatter (Linux only, broken on macOS)
        };
      };
    in {
      devShells.default = pkgs.mkShell {
        name = "dev";

        # Available packages on https://search.nixos.org/packages
        packages = with pkgs;
          [
            alejandra # Nix
            nixd
            statix
            deadnix

            zigpkgs.master # Zig Tools
            lldb # Debugger
            gdb # Alternative debugger
          ]
          ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
            # Linux-only debugging tools
            valgrind # Memory debugging (Linux only)
          ]
          ++ [
            zls.packages.${system}.zls # Zig Language Server
          ]
          ++ builtins.attrValues scriptPackages;

        shellHook = ''
          echo "Welcome to the Zig development shell!"
          echo "Available commands:"
          echo "  dx - Edit flake.nix"
          echo "  zx - Edit build.zig"
          echo "  zig build - Build the project"
          echo "  zig test - Run tests"
          echo "  nix fmt - Format code"
        '';
      };

      # Example package build (uncomment and customize for your project)
      # packages = {
      #   default = pkgs.stdenv.mkDerivation {
      #     pname = "my-zig-project";
      #     version = "0.0.1";
      #     src = ./.;  # Use ./. for your project source
      #     nativeBuildInputs = [pkgs.zigpkgs.master];
      #     buildPhase = ''
      #       zig build
      #     '';
      #     installPhase = ''
      #       mkdir -p $out/bin
      #       # Copy built executables to $out/bin
      #       # Adjust this based on your project structure
      #       if [ -d "zig-out/bin" ]; then
      #         cp -r zig-out/bin/* $out/bin/
      #       fi
      #     '';
      #     meta = with pkgs.lib; {
      #       description = "My Zig project";
      #       homepage = "https://github.com/connerohnesorge/my-zig-project";
      #       license = licenses.mit;
      #       maintainers = with maintainers; [connerohnesorge];
      #     };
      #   };
      # };

      formatter = treefmt-nix.lib.mkWrapper pkgs treefmtModule;
    });
}
