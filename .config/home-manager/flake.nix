{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    stylix.url = "github:danth/stylix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    stylix,
    home-manager,
    ...
  }: {
    homeConfigurations = {
      # Personal macOS configuration
      "connerohnesorge@Conners-MacBook-Air.local" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        extraSpecialArgs = {username = "connerohnesorge";};
        modules = [
          ./home-darwin.nix
        ];
      };

      # Work macOS configuration
      "cohnesor@CB14957.local" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        extraSpecialArgs = {username = "cohnesor";};
        modules = [
          ./home-darwin.nix
        ];
      };

      # Personal Linux configuration
      "connerohnesorge" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {username = "connerohnesorge";};
        modules = [
          stylix.homeManagerModules.stylix
          ./home.nix
        ];
      };

      # Work Linux configuration (if needed)
      "cohnesor" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {username = "cohnesor";};
        modules = [
          stylix.homeManagerModules.stylix
          ./home.nix
        ];
      };
    };
  };
}
