{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    direnv-instant.url = "github:Mic92/direnv-instant";
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
    };

    constatus.url = "github:connerohnesorge/constatus";
    constatus.inputs.nixpkgs.follows = "nixpkgs";

    cnb.url = "git+https://software.cottinghambutler.com/pantheon/cnb";
    cnb.inputs.nixpkgs.follows = "nixpkgs";

    catls.url = "github:connerohnesorge/catls";
  };

  outputs = inputs @ {
    nixpkgs,
    home-manager,
    llm-agents,
    direnv-instant,
    cnb,
    constatus,
    catls,
    ...
  }: {
    homeConfigurations = {
      # Personal macOS configuration
      "connerohnesorge@Conners-MacBook-Air.local" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        extraSpecialArgs = {
          username = "connerohnesorge";
        };
        modules = [
          ./home-darwin.nix
        ];
      };

      # Work macOS configuration
      # "cohnesor@Mac.home.local" = let
      "cohnesor@CB14957.local" = let
        # pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
          config.allowUnfree = true;
          overlays = [];
        };
      in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            username = "cohnesor";
            inherit llm-agents;
            inherit direnv-instant;
            inherit constatus;
            inherit cnb;
            inherit catls;
          };
          modules = [
            ./home-darwin.nix
          ];
        };

      # Personal Linux configuration
      "connerohnesorge" = let
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
          overlays = [];
        };
      in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {username = "connerohnesorge";};
          modules = [
            ./home.nix
          ];
        };

      # Work Linux configuration (if needed)
      "cohnesor" = let
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
          overlays = [];
        };
      in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {username = "cohnesor";};
          modules = [
            ./home.nix
          ];
        };
    };
  };
}
