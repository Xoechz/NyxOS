# The system config base for FredPC
{ inputs, ... }:
let system = "x86_64-linux"; in {
  flake.nixosConfigurations.FredPC = inputs.nixpkgs.lib.nixosSystem {
    system = system;
    specialArgs = {
      system = system;
      pkgs-stable = import inputs.nixpkgs-stable {
        system = system;
        config.allowUnfree = true;
      };
      swapSize = 32; # GB
      users = [ "elias" "fred" "gerhard" ];
    };
    modules = [
      inputs.self.modules.nixos.fredPC
      inputs.home-manager.nixosModules.home-manager
    ];
  };

  flake.modules.nixos.fredPC = { lib, modulesPath, ... }: {
    imports = with inputs.self.modules.nixos; [
      firefox
      chromium-no-gpu
      languageDe
      fonts
      baseDesktop
      steam
      kde
      ssh
      firewallDesktop
      distributedBuild
      nh
      homeManager
      grub
      basicSystem
      swap
      printing
      sound
      cpuIntel
      nixIndex
      terminal
      elias
      others
      cliUtilities
      tv
      winboat
    ] ++ [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    home-manager.sharedModules = with inputs.self.modules.homeManager; [
      libreoffice
      email
      pdf
      media
      kdeConnect
      vscode
      guiUtilities
    ];

    home-manager = {
      extraSpecialArgs = {
        pkgs-stable = import inputs.nixpkgs-stable {
          system = system;
          config.allowUnfree = true;
        };
        showBattery = false; # Show battery status in the system tray (not needed for a desktop PC)
      };
      users = {
        elias = {
          imports = with inputs.self.modules.homeManager; [
            elias
            git
          ];

          home.stateVersion = "24.05";
        };
        fred = {
          imports = with inputs.self.modules.homeManager; [
            fred
          ];

          home.stateVersion = "24.05";
        };
        gerhard = {
          imports = with inputs.self.modules.homeManager; [
            gerhard
          ];

          home.stateVersion = "24.05";
        };
      };
    };

    boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "nvme" "ums_realtek" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/62e51310-97d9-448f-812f-fd6ec8ad0106";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/E7AE-32D1";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

    fileSystems."/run/media/OldWindows" = {
      device = "/dev/disk/by-uuid/A60E66E70E66B04B";
      fsType = "ntfs";
    };

    fileSystems."/run/media/Windows" = {
      device = "/dev/disk/by-uuid/A48C4D438C4D10EA";
      fsType = "ntfs";
    };

    networking = {
      useDHCP = lib.mkDefault true;
      hostName = "FredPC";
      networkmanager.enable = true;
    };

    nixpkgs.hostPlatform = system;

    boot.loader.grub.useOSProber = true;

    system.stateVersion = "25.05";
  };
}
