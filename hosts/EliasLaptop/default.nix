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

  hardware.nvidia.prime = {
    reverseSync.enable = true;
    # Enable if using an external GPU
    allowExternalGpu = false;

    # Make sure to use the correct Bus ID values for your system!
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:2:0:0";
  };

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
      MIIDuTCCAqGgAwIBAgIIS+pgHphgA5MwDQYJKoZIhvcNAQELBQAwFDESMBAGA1UE
      AxMJbG9jYWxob3N0MB4XDTI1MTIyMDEyMTM0MVoXDTI2MTIyMDEyMTM0MVowFDES
      MBAGA1UEAxMJbG9jYWxob3N0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC
      AQEAndQe+6U7FOiGPLakulK6TcQiADSGH8qoiAW5oWU92gBkWcschbo4vW+Abgmw
      HfdKd6Ok3+Ivy9VLmzh7I0Aow1osKTGwGBMF5/t7SwnKlW/6wUgLJ6oL6W6uYe1r
      VoLg02ZOJP2PW1T6RZ+UbPB7TlzXYyyelncD/TdJY7C2OVGx1fSTj/hoCZQv276M
      nzDLtQYYsDqoGuHNGPFUrSTyflXIR6Lm3A+Nx9gFxuJardcMugzlRSw+XsTWeXM3
      g31+m9yu4hwRL7+ZpLKnXGxkt6BRRBS1IaGEobzDs6eMVeLrhE2vq2t2bJGxx6VK
      nr3jRR9Gvl/zA+/gHD3tNOWMqwIDAQABo4IBDTCCAQkwDAYDVR0TAQH/BAIwADAO
      BgNVHQ8BAf8EBAMCBaAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwEwaAYDVR0RAQH/
      BF4wXIIJbG9jYWxob3N0gg8qLmRldi5sb2NhbGhvc3SCDiouZGV2LmludGVybmFs
      ghRob3N0LmRvY2tlci5pbnRlcm5hbIIYaG9zdC5jb250YWluZXJzLmludGVybmFs
      MA8GCisGAQQBgjdUAQEEAQUwKQYDVR0OBCIEILh4X4NZqvBYW4onHgKKCAjwKeb3
      gkusvhFfWpNcFWM9MCsGA1UdIwQkMCKAILh4X4NZqvBYW4onHgKKCAjwKeb3gkus
      vhFfWpNcFWM9MA0GCSqGSIb3DQEBCwUAA4IBAQCRSL+ezCneXPniEvcHpVmfJC6C
      yl0XP9H8pncKCBuEEhL+zqooyhEvuC3pgRKoXdmfMGrExdBULViG+Y+h0f0Jb+Cs
      TGw/zVqXAIPPlsvz5hcrVI2EmkBP3UfG9B/X9RByRZW7NQM6X9eWqG/8f5DbYdd9
      uSdv03RtQzgYKOotmBbv/gKhC6lteOYj7zan5WBhX1JY5j563URR2qI/mmQeIEkS
      qLmUr1d1XfNdnk38l/yr4nI6N2M/jfuXAMtXc14a7DueQBxLMV1NGtRKADsgeZoS
      el0WeiuFAqEn+ZK1Coh580RE0lacuIVvpBw/6QMSpuTQUZvFWw15e2tEUbyu
      -----END CERTIFICATE-----
    ''
  ];

  system.stateVersion = "24.05";
}
