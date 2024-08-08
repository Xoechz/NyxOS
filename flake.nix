{
  description = "The base flake for NyxOS";

  inputs = {
    # The main channel is nixos stable, that may change in the future
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    # The same goes for the home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      # demo is a vm that I used for testing, may be deleted in the future
      demo = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/demo
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = inputs;
            home-manager.users.elias = import ./home;
          }
        ];
      };
      EliasLaptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # right now there arent many differences between hosts, only hardware settings, 
          # but for gaming i probably have to change graphics settings for AMD and NVIDIA
          ./hosts/EliasLaptop
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

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
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = inputs;
            home-manager.users.elias = import ./home;
          }
        ];
      };
    };
  };
}
