# The system config base for EliasLaptop
{ pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/system.nix
      ../../modules/kde.nix
      ../../modules/overlays.nix
      ../../modules/steam.nix
      ../../modules/nvidia.nix
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
      useOSProber = false;
      memtest86.enable = true;
      extraEntries = ''
        menuentry "Windows" --class windows --class os {
          insmod ntfs
          search --no-floppy --set=root --fs-uuid C236-4D6C
          chainloader /efi/Microsoft/Boot/bootmgfw.efi
        };
        menuentry "UEFI Firmware Settings" --class efi {
          fwsetup
        }
      '';
    };

  networking.hostName = "EliasLaptop";

  # Enable networking
  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    btop-cuda
    nvtopPackages.nvidia
  ];

  # enables support for Bluetooth
  hardware.bluetooth.enable = true;
  # powers up the default Bluetooth controller on boot
  hardware.bluetooth.powerOnBoot = true;
  # allow reading device charge
  hardware.bluetooth.settings = {
    General = {
      Experimental = true;
    };
  };

  # swap
  zramSwap.enable = true;
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 18 * 1024; # 18GB
    randomEncryption.enable = true;
  }];

  # power management
  services.auto-cpufreq.enable = false;
  services.power-profiles-daemon.enable = false;

  services.thermald.enable = true;
  services.tlp =
    {
      enable = true;
      settings = {
        # CPU governors and energy/perf policy
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

        # Performance caps to reduce heat/noise on AC, save battery on BAT
        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 90;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 50;

        CPU_BOOST_ON_AC = "1";
        CPU_BOOST_ON_BAT = "0";

        # PCIe and runtime power management
        PCIE_ASPM_ON_AC = "default";
        PCIE_ASPM_ON_BAT = "powersupersave";

        RUNTIME_PM_ON_AC = "on";
        RUNTIME_PM_ON_BAT = "auto";
        RUNTIME_PM_DRIVER_BLACKLIST = "nouveau amdgpu nvidia";
        RUNTIME_PM_DEVICE_BLACKLIST = "";

        # USB autosuspend
        USB_AUTOSUSPEND = 0;

        # SATA link power management
        SATA_LINKPWR_ON_AC = "med_power_with_dipm";
        SATA_LINKPWR_ON_BAT = "min_power";

        # WiFi power saving
        WIFI_PWR_ON_AC = 1;
        WIFI_PWR_ON_BAT = 5;

        # Audio power saving
        SOUND_POWER_SAVE_ON_AC = 1;
        SOUND_POWER_SAVE_ON_BAT = 1;

        # Bluetooth power saving
        BT_POWER = 1;

        # Battery charge thresholds
        START_CHARGE_THRESH_BAT0 = 40;
        STOP_CHARGE_THRESH_BAT0 = 80;

        # Optional platform profiles (if supported)
        PLATFORM_PROFILE_ON_AC = "balanced-performance";
        PLATFORM_PROFILE_ON_BAT = "low-power";
      };
    };

  # services.github-runners.default = {
  #   enable = true;
  #   tokenFile = "/run/secrets/github-runner/default.token";
  #   url = "https://github.com/swk5-2025ws/delifhery-bb-g1-leonhardsberger";
  # };

  # devcert for local https development
  # create it with dotnet dev-certs https --format PEM -ep devcert.crt
  security.pki.certificates = [
    ''
      DevCert
      =========
      -----BEGIN CERTIFICATE-----
      MIIDXzCCAkegAwIBAgIIUHjB2p5JLhowDQYJKoZIhvcNAQELBQAwFDESMBAGA1UE
      AxMJbG9jYWxob3N0MB4XDTI1MTExMzE2NTUwMFoXDTI2MTExMzE2NTUwMFowFDES
      MBAGA1UEAxMJbG9jYWxob3N0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC
      AQEAuLfoxBS3wuJQlnHgVwhPl6A2Lx4ZrLO3QvMKDB2ll0zDEFrIU9mQdZsEOBa6
      G5usqKRiPSaXT0tDM1CFt0ReaNLFZVzHyn38TqtUdG61uH+rqOEjlp6IDVrQ55Zm
      LlylX/PS40BmejiTw1TlAKuQ9C8OOkWGfYIoh5sot4aypcjrAbKYUhJGj2qflfcm
      DPBOAKN7AoBDReguWavoSku9EiwPDzZpAMxZFM6sO/4RrcaOadtf1onsrwGc+dJv
      P2zm95Vzv21WXbtSR6N+eRx5bqArEejeQcJ6cRKvJEml3xPVewrgRh/+/ehBxsI/
      c8ICkt3XX0ewxqZMXF4AnId1aQIDAQABo4G0MIGxMAwGA1UdEwEB/wQCMAAwDgYD
      VR0PAQH/BAQDAgWgMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMBMGgGA1UdEQEB/wRe
      MFyCCWxvY2FsaG9zdIIPKi5kZXYubG9jYWxob3N0gg4qLmRldi5pbnRlcm5hbIIU
      aG9zdC5kb2NrZXIuaW50ZXJuYWyCGGhvc3QuY29udGFpbmVycy5pbnRlcm5hbDAP
      BgorBgEEAYI3VAEBBAEEMA0GCSqGSIb3DQEBCwUAA4IBAQCmpCO6nyGkN6Q1JixF
      rw3tstUJcnuaHJYFV2stNnzhqd0o4kiaFolUx8x8hU5e8Jjbfv/v63inepQYLKj9
      dEY6948K2SLnB+X5+zczxHOBJCA5VBtpFIUKpu+nSPLZLwn/Do++OQmkPb72ktwD
      LCuLYncvJbAhEdr/+yoLuBqTQlv8VlEwpX/m+/3+kOjN/vQfvUSpE7yuA2BY7jce
      z7AR6zUBA/4perHTPj25t5gB0fAtmSnoH9hi23ffEdJK0Z1Vs4hj/wresnxk269k
      bRWwGL41pkOa9/gBffLHAN0Qj4HIAK7iHyTdAxR7UyZILGYBQ9zoByXUx8GCorkw
      QZzT
      -----END CERTIFICATE-----
    ''
  ];

  system.stateVersion = "24.05";
}
