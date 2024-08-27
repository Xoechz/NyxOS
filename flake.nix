{
  description = "The base flake for NyxOS";

  inputs = {
    # The main channel is nixos stable, that may change in the future
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";

    # The same goes for the home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Plasma manager is used to port the plasma desktop via nixos
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Auto styling and theming through the stylix package
    stylix.url = "github:danth/stylix";
  };

  outputs = { nixpkgs, home-manager, plasma-manager, stylix, ... }@inputs: {
    nixosConfigurations = {
      EliasLaptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # right now there arent many differences between hosts, only hardware settings, 
          # but for gaming i probably have to change graphics settings for AMD and NVIDIA
          ./hosts/EliasLaptop
          stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];
            home-manager.extraSpecialArgs = inputs;
            home-manager.users.elias = import ./home;
          }
        ];
      };
      EliasPC = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # Not yet in use
          ./hosts/EliasPC
          stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];
            home-manager.extraSpecialArgs = inputs;
            home-manager.users.elias = import ./home;
          }
        ];
      };
    };
  };
}
