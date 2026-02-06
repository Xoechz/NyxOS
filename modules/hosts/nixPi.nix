# The system config base for NixPi
{ inputs, ... }:
let system = "aarch64-linux"; in {
  flake.nixosConfigurations.NixPi = inputs.nixpkgs.lib.nixosSystem {
    system = system;
    specialArgs = {
      system = system;
      pkgs-stable = import inputs.nixpkgs-stable {
        system = system;
        config.allowUnfree = true;
      };
    };
    modules = [
      inputs.self.modules.nixos.nixPi
      inputs.home-manager.nixosModules.home-manager
    ];
  };

  flake.modules.nixos.nixPi = { lib, ... }: {
    imports = with inputs.self.modules.nixos; [
      languageEn
      basicFonts
      catppuccin
      ssh
      blocky
      firewallServer
      distributedBuild
      nh
      homeManager
      basicSystem
      swap8
      terminal
      elias
      cliUtilities
      basics
    ] ++ [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    home-manager.users.elias = {
      imports = with inputs.self.modules.homeManager; [
        elias
        git
      ];

      home.stateVersion = "24.05";
    };

    boot.initrd.availableKernelModules = [ "usbhid" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ ];
    boot.extraModulePackages = [ ];

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

    # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
    boot.loader.grub.enable = false;

    # Enables the generation of /boot/extlinux/extlinux.conf
    boot.loader.generic-extlinux-compatible.enable = true;

    system.stateVersion = "24.05";
  };
}
