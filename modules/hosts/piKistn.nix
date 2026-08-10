# The system config base for PiKistn
{ inputs, ... }:
let system = "aarch64-linux"; in {
  flake.nixosConfigurations.PiKistn = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = {
      inherit system;
      pkgs-stable = import inputs.nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };
      swapSize = 2; # GB
      users = [ "kistn" ];
    };
    modules = [
      inputs.self.modules.nixos.piKistn
      inputs.home-manager.nixosModules.home-manager
    ];
  };

  flake.modules.nixos.piKistn = { lib, modulesPath, pkgs, ... }: {
    imports = with inputs.self.modules.nixos; [
      # bierkistn.nix
      bierkistn
      # desktop.nix
      basic-fonts
      language-en
      # network.nix
      ssh
      # nix.nix
      home-manager
      nh
      # system.nix
      basic-system
      bluetooth
      sound
      swap
      # terminal.nix
      terminal
      # utilities.nix
      cli-utilities
    ] ++ [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    services.cage = {
      enable = true;
      user = "kistn";
      program = "${inputs.bierkistn-radio.packages.${system}.bierkistnRadio}/bin/bierkistnRadio";
      environment = {
        QT_QPA_PLATFORM = "wayland";
        XDG_CACHE_HOME = "/home/kistn/.cache";
      };
    };

    users.users.kistn = {
      isNormalUser = true;
      description = "BierKistn Radio kiosk user";
      extraGroups = [ "networkmanager" "bluetooth" "audio" "video" "input" "wheel" ];
      shell = pkgs.zsh;
    };

    home-manager = {
      extraSpecialArgs = {
        pkgs-stable = import inputs.nixpkgs-stable {
          inherit system;
          config.allowUnfree = true;
        };
        showBattery = false;
      };
      users.kistn = {
        imports = with inputs.self.modules.homeManager; [
          # utilities.nix
          git
        ];

        home.stateVersion = "25.11";
      };
    };

    boot.initrd.availableKernelModules = [ "usbhid" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ ];
    boot.extraModulePackages = [ ];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/00000000-0000-0000-0000-000000000000";
      fsType = "ext4";
    };

    networking = {
      useDHCP = lib.mkDefault true;
      hostName = "PiKistn";
      networkmanager.enable = true;
    };

    nixpkgs.hostPlatform = system;

    boot.loader.grub.enable = false;
    boot.loader.generic-extlinux-compatible.enable = true;

    system.stateVersion = "25.11";
  };
}
