# The system config base for NixPi
{ inputs, ... }:
let system = "aarch64-linux"; in {
  flake.nixosConfigurations.NixPi = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = {
      inherit system;
      pkgs-stable = import inputs.nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };
      swapSize = 8; # GB
      users = [ "elias" ];
    };
    modules = [
      inputs.self.modules.nixos.nixPi
      inputs.home-manager.nixosModules.home-manager
    ];
  };

  flake.modules.nixos.nixPi = { lib, modulesPath, ... }: {
    imports = with inputs.self.modules.nixos; [
      # desktop.nix
      language-en
      # network.nix
      blocky
      cloudflared
      firewall-server
      ssh
      # nix.nix
      distributed-build
      home-manager
      # system.nix
      pi4-system
      swap
      # terminal.nix
      zsh
      # users.nix
      elias
      # utilities.nix
      cli-utilities-minimal
    ] ++ [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    home-manager = {
      extraSpecialArgs = {
        pkgs-stable = import inputs.nixpkgs-stable {
          inherit system;
          config.allowUnfree = true;
        };
        showBattery = false; # Show battery status in the system tray (not needed for a server)
      };
      users.elias = {
        imports = with inputs.self.modules.homeManager; [
          # users.nix
          elias
          # utilities.nix
          git
        ];

        home.stateVersion = "24.05";
      };
    };

    hardware.raspberry-pi.firmware = {
      enable = true;
      uboot.enable = true;
    };

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
      fsType = "ext4";
    };

    networking = {
      useDHCP = lib.mkDefault true;
      hostName = "NixPi";
      networkmanager.enable = true;
    };

    nixpkgs.hostPlatform = system;
    system.stateVersion = "25.11";
  };
}
