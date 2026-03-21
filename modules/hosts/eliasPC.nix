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
      swapSize = 32; # GB
      users = [ "elias" ];
    };
    modules = [
      inputs.self.modules.nixos.eliasPC
      inputs.home-manager.nixosModules.home-manager
    ];
  };

  flake.modules.nixos.eliasPC = { lib, modulesPath, ... }: {
    imports = with inputs.self.modules.nixos; [
      # desktop.nix
      base-desktop
      catppuccin
      fonts
      language-en
      # dev.nix
      dev-certs
      dotnet
      go
      java
      latex
      python
      # games.nix
      steam
      # network.nix
      firewall-desktop
      ssh
      vpn
      # niri.nix
      niri
      # nix.nix
      distributed-builder
      home-manager
      nh
      # optimizations.nix
      optimizations-pc
      # system.nix
      basic-system
      cpu-intel
      gpu-amd
      grub
      printing
      sound
      swap
      # terminal.nix
      nix-index
      terminal
      # users.nix
      elias
      # utilities.nix
      cli-utilities
      # virtualization.nix
      docker
    ] ++ [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    home-manager = {
      extraSpecialArgs = {
        pkgs-stable = import inputs.nixpkgs-stable {
          system = system;
          config.allowUnfree = true;
        };
        isMobile = false; # Show battery status in the system tray (not needed for a desktop PC)
      };
      users.elias = {
        imports = with inputs.self.modules.homeManager; [
          # ai.nix
          opencode
          opencode-dotnet
          opencode-java
          # apps.nix
          discord
          email
          idea
          kde-connect
          libreoffice
          media
          media-editors
          nomacs
          obs
          pdf
          teams
          vscode
          # browser.nix
          betterfox
          # games.nix
          minecraft
          # network.nix
          sailing
          # users.nix
          elias
          # utilities.nix
          git
          gui-utilities
        ];

        home.stateVersion = "24.05";
      };
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

    networking = {
      useDHCP = lib.mkDefault true;
      hostName = "EliasPC";
      networkmanager = {
        enable = true;
        ensureProfiles.profiles."wired-wol" = {
          connection = {
            id = "wired-wol";
            type = "ethernet";
            interface-name = "enp5s0";
            autoconnect = "true";
            autoconnect-priority = "999";
          };
          "ethernet" = {
            wake-on-lan = "64"; # magic packet bitmask (0x40)
          };
          ipv4.method = "auto";
          ipv6 = {
            method = "auto";
            addr-gen-mode = "default";
          };
        };
      };
      interfaces.enp5s0.wakeOnLan.enable = true;
      firewall = {
        allowedUDPPorts = [ 9 ]; # Wake-on-LAN uses UDP port 9
      };
    };

    nixpkgs.hostPlatform = system;

    system.stateVersion = "24.05";
  };
}
