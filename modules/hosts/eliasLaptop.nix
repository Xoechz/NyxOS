# The system config base for EliasLaptop
{ inputs, ... }:
let system = "x86_64-linux"; in {
  flake.nixosConfigurations.EliasLaptop = inputs.nixpkgs.lib.nixosSystem {
    system = system;
    specialArgs = {
      system = system;
      pkgs-stable = import inputs.nixpkgs-stable {
        system = system;
        config.allowUnfree = true;
      };
      swapSize = 18; # GB
      users = [ "elias" ];
    };
    modules = [
      inputs.self.modules.nixos.eliasLaptop
      inputs.home-manager.nixosModules.home-manager
    ];
  };

  flake.modules.nixos.eliasLaptop = { lib, modulesPath, ... }: {
    imports = with inputs.self.modules.nixos; [
      # desktop.nix
      baseDesktop
      catppuccin
      fonts
      languageEn
      # dev.nix
      devCerts
      dotnet
      go
      java
      latex
      python
      # games.nix
      steam
      # network.nix
      firewallDesktop
      ssh
      vpn
      warp
      # niri.nix
      niri
      # nix.nix
      distributedBuild
      homeManager
      nh
      # optimizations.nix
      optimizationsLaptop
      # system.nix
      basicSystem
      bluetooth
      cpuIntel
      gpuNvidia
      grub
      printing
      sound
      swap
      # terminal.nix
      nixIndex
      terminal
      # users.nix
      elias
      # utilities.nix
      cliUtilities
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
        isMobile = true; # Show battery status in the system tray
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
          kdeConnect
          libreoffice
          media
          mediaEditors
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
          guiUtilities
        ];

        home.stateVersion = "24.05";
      };
    };

    boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/f75b7ec9-ae4e-414d-879e-afda5168c71e";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/C08E-50B6";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

    networking = {
      useDHCP = lib.mkDefault true;
      hostName = "EliasLaptop";
      networkmanager.enable = true;
    };

    nixpkgs.hostPlatform = system;

    boot.loader.grub.extraEntries = ''
      menuentry "Windows" --class windows --class os {
        insmod ntfs
        search --no-floppy --set=root --fs-uuid C236-4D6C
        chainloader /efi/Microsoft/Boot/bootmgfw.efi
      };
      menuentry "UEFI Firmware Settings" --class efi {
        fwsetup
      }
    '';

    hardware.nvidia.prime = {
      reverseSync.enable = true;
      # Enable if using an external GPU
      allowExternalGpu = false;

      # Make sure to use the correct Bus ID values for your system!
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:2:0:0";
    };

    system.stateVersion = "24.05";
  };
}
