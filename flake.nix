{
  description = "The base flake for NyxOS";

  inputs = {
    # The main channel is nixos stable, that may change in the future
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";

    # The same goes for the home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Plasma manager is used to port the plasma desktop via nixos
    plasma-manager = {
      url = "github:sidmoreoss/plasma-manager/krohnkite";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Auto styling and theming through the catppuccin package
    catppuccin.url = "github:catppuccin/nix";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, nixpkgs-stable, home-manager, plasma-manager, catppuccin, ... }@inputs: {
    nixosConfigurations = {
      EliasLaptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          pkgs-stable = import nixpkgs-stable {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        };
        modules = [
          # right now there arent many differences between hosts, only hardware settings, 
          # but for gaming i probably have to change graphics settings for AMD and NVIDIA
          ./hosts/EliasLaptop
          catppuccin.nixosModules.catppuccin
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
        specialArgs = {
          pkgs-stable = import nixpkgs-stable {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        };
        modules = [
          ./hosts/EliasPC
          catppuccin.nixosModules.catppuccin
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
