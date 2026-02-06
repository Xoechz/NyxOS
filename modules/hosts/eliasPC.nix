# The system config base for EliasPC
{ inputs, ... }:
let system = "x86_64-linux"; in {
  flake.nixosConfigurations.EliasPC = inputs.nixpkgs.lib.nixosSystem {
    system = system;
    specialArgs = {
      system = system;
      pkgs-stable = import inputs.nixpkgs-stable {
        system = system;
        config.allowUnfree = true;
      };
    };
    modules = [
      inputs.self.modules.nixos.eliasPC
      inputs.home-manager.nixosModules.home-manager
    ];
  };

  flake.modules.nixos.eliasPC = { lib, ... }: {
    imports = with inputs.self.modules.nixos; [
      languageEn
      fonts
      catppuccin
      python
      latex
      dotnet
      java
      go
      docker
      devCerts
      steam
      kde
      ssh
      firewallDesktop
      vpn
      distributedBuilder
      nh
      homeManager
      grub
      basicSystem
      optimizationsPC
      swap32
      printing
      sound
      cpuIntel
      gpuAmd
      nixIndex
      terminal
      elias
      cliUtilities
      basics
      autoUpdate
    ] ++ [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    home-manager.users.elias = {
      imports = with inputs.self.modules.homeManager; [
        defaultApplicationsKde
        libreoffice
        email
        teams
        pdf
        media
        discord
        kdeConnect
        vscode
        betterfox
        minecraft
        plasma-manager
        sailing
        elias
        git
        guiUtilities
      ];

      home.stateVersion = "24.05";
    };

    boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/e49cb94a-4cdd-4627-adb7-e60dd5865762";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/43CA-60A3";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

    fileSystems."/run/media/elias/4TB-HDD" = {
      device = "/dev/disk/by-uuid/5939832d-c16a-4b0d-bf9c-fa07d41fd538";
      fsType = "ext4";
    };

    fileSystems."/run/media/elias/100GB-SSD" = {
      device = "/dev/disk/by-uuid/2b788cd1-fa01-45ee-bf76-6c396e06015f";
      fsType = "ext4";
    };

    networking = {
      useDHCP = lib.mkDefault true;
      hostName = "EliasPC";
      networkmanager.enable = true;
    };

    nixpkgs.hostPlatform = system;

    system.stateVersion = "24.05";
  };
}
