# The system config base for EliasPC
{ ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/system.nix
      ../../modules/kde.nix
      ../../modules/steam.nix
      ../../modules/amd.nix
      ../../modules/dev.nix
      ../../modules/styling.nix
      ../../modules/language_en_at.nix
    ];

  # Bootloader
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.grub =
    {
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
      extraEntries = ''
        menuentry "UEFI Firmware Settings" --class efi {
          fwsetup
        }
      '';
    };

  fileSystems."/run/media/elias/4TB-HDD" =
    {
      device = "/dev/disk/by-uuid/5939832d-c16a-4b0d-bf9c-fa07d41fd538";
      fsType = "ext4";
    };

  fileSystems."/run/media/elias/100GB-SSD" =
    {
      device = "/dev/disk/by-uuid/2b788cd1-fa01-45ee-bf76-6c396e06015f";
      fsType = "ext4";
    };

  networking.hostName = "EliasPC";

  # Enable networking
  networking.networkmanager.enable = true;

  # swap
  zramSwap.enable = true;
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 32 * 1024; # 32GB
    randomEncryption.enable = true;
  }];

  # Power management (Intel desktop-friendly defaults)
  services.thermald.enable = true;
  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      # Responsive CPU scaling
      CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_BOOST_ON_AC = "1";

      # Device runtime power management (avoid GPUs)
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_DRIVER_BLACKLIST = "nouveau amdgpu nvidia";

      # Safe disk & USB savings
      SATA_LINKPWR_ON_AC = "med_power_with_dipm";
      USB_AUTOSUSPEND = 1;

      # Audio powersave when idle
      SOUND_POWER_SAVE_ON_AC = 1;

      # Keep PCIe ASPM default for desktop stability
      PCIE_ASPM_ON_AC = "default";
    };
  };


  system.stateVersion = "24.05";
}
