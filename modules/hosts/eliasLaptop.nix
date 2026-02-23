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
      languageEn
      fonts
      baseDesktop
      catppuccin
      python
      latex
      dotnet
      java
      go
      docker
      devCerts
      steam
      niri
      ssh
      firewallDesktop
      vpn
      distributedBuild
      nh
      homeManager
      grub
      basicSystem
      optimizationsLaptop
      swap
      bluetooth
      printing
      sound
      cpuIntel
      gpuNvidia
      nixIndex
      terminal
      elias
      cliUtilities
    ] ++ [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    home-manager = {
      extraSpecialArgs = {
        pkgs-stable = import inputs.nixpkgs-stable {
          system = system;
          config.allowUnfree = true;
        };
        showBattery = true; # Show battery status in the system tray
      };
      users.elias = {
        imports = with inputs.self.modules.homeManager; [
          libreoffice
          email
          teams
          pdf
          media
          mediaEditors
          obs
          discord
          kdeConnect
          vscode
          betterfox
          minecraft
          sailing
          elias
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
