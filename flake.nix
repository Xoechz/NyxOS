{
  description = "The base flake for NyxOS";

  inputs = {
    # The main channel is nixos stable, that may change in the future
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-very-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # The same goes for the home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Plasma manager is used to port the plasma desktop via nixos
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    # Auto styling and theming through the catppuccin package
    catppuccin.url = "github:catppuccin/nix";

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-index for better command not found suggestions
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # to overlay the newest nom version
    nix-output-monitor = {
      url = "github:maralorn/nix-output-monitor";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # betterfox
    betterfox-nix = {
      url = "github:HeitorAugustoLN/betterfox-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixpkgs-stable, nixpkgs-very-unstable, home-manager, plasma-manager, catppuccin, nix-index-database, ... }@inputs:
    let
      # Helper function to create pkgs for a given system
      mkPkgs = system: nixpkgsInput: import nixpkgsInput {
        inherit system;
        config.allowUnfree = true;
      };

      # Helper function to create specialArgs with stable and very-unstable pkgs
      mkSpecialArgs = system: withVeryUnstable: {
        inherit inputs system;
        pkgs-stable = mkPkgs system nixpkgs-stable;
      } // (if withVeryUnstable then {
        pkgs-very-unstable = mkPkgs system nixpkgs-very-unstable;
      } else { });

      # Helper function to create home-manager configuration
      mkHomeManagerConfig = system: users: {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          sharedModules = [ plasma-manager.homeModules.plasma-manager ];
          extraSpecialArgs = inputs // {
            pkgs-stable = mkPkgs system nixpkgs-stable;
          };
          users = builtins.listToAttrs (map
            (user: {
              name = user;
              value = import ./home/${user}.nix;
            })
            users);
        };
      };

      # Base modules used by most desktop systems
      baseModules = [
        catppuccin.nixosModules.catppuccin
        nix-index-database.nixosModules.nix-index
        home-manager.nixosModules.home-manager
      ];

      # Helper function to create a full NixOS system configuration
      mkSystem = { system, hostPath, homeManagerUsers, withVeryUnstable ? false, extraModules ? [ ] }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = mkSpecialArgs system withVeryUnstable;
          modules = [
            hostPath
          ] ++ extraModules ++ (if homeManagerUsers != [ ] then [
            (mkHomeManagerConfig system homeManagerUsers)
          ] else [ ]);
        };
    in
    {
      nixosConfigurations = {
        # Laptop with full home-manager setup
        EliasLaptop = mkSystem {
          system = "x86_64-linux";
          hostPath = ./hosts/EliasLaptop;
          homeManagerUsers = [ "elias" ];
          withVeryUnstable = true;
          extraModules = baseModules;
        };

        # Desktop with full home-manager setup
        EliasPC = mkSystem {
          system = "x86_64-linux";
          hostPath = ./hosts/EliasPC;
          homeManagerUsers = [ "elias" ];
          withVeryUnstable = true;
          extraModules = baseModules;
        };

        # Raspberry Pi server without home-manager
        NixPi = mkSystem {
          system = "aarch64-linux";
          hostPath = ./hosts/NixPi;
          homeManagerUsers = [ ];
        };

        # Multi-user desktop
        FredPC = mkSystem {
          system = "x86_64-linux";
          hostPath = ./hosts/FredPC;
          homeManagerUsers = [ "fred" "elias" "gerhard" ];
          extraModules = baseModules;
        };
      };
    };
}
