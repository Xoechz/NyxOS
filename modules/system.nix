{ pkgs, ... }:
{
  nix = {
    settings = {
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      # enable flakes and new nix commands
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "elias" "nixremote" ];
    };

    # Optimise nix store usage
    optimise = {
      automatic = true;
      dates = "weekly";
    };
  };

  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 3";
      dates = "weekly";
    };
    flake = "/home/elias/NyxOS";
  };

  # user setup
  users.users.elias = {
    isNormalUser = true;
    description = "Elias";
    # lpadmin is needed for printer setup
    # video is needed for dvb-s access
    extraGroups = [ "networkmanager" "wheel" "lpadmin" "video" ];
    shell = pkgs.zsh;
  };

  # Set your time zone.
  time.timeZone = "Europe/Vienna";

  # Install firefox.
  programs.firefox = {
    enable = true;
  };

  # Enable CUPS to print documents.
  services.printing =
    {
      enable = true;
      drivers = with pkgs; [ hplip ];
    };

  security.rtkit.enable = true;

  # Enable sound with pipewire.
  services = {
    dbus.packages = [ pkgs.gcr ];

    geoclue2.enable = true;

    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };

  # Enable firewall settings
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      # SSH
      22
      # HTTP
      80
      # HTTPS
      443
      # Spotify
      57621
      # Steam Local Network Game Transfer and Remote Play
      27015
      27036
      27040
      # ddev
      9003
      # DNS
      53
    ];
    allowedUDPPorts = [
      # Spotify
      5353
      # Stardew Valley LAN Multiplayer
      24642
      # DNS
      53
      #Steam
      27015
    ];
    allowedTCPPortRanges = [
      # KDE Connect
      { from = 1714; to = 1764; }
    ];
    allowedUDPPortRanges = [
      # KDE Connect
      { from = 1714; to = 1764; }
      # Steam Local Network Game Transfer and Remote Play
      { from = 27031; to = 27036; }
    ];
    trustedInterfaces = [ "docker0" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    wget
    curl

    fastfetch
    zip
    xz
    unzip

    lm_sensors
    sysstat

    clinfo

    wayland-utils
    gparted

    openssl

    iptables
    inetutils

    gnome-multi-writer

    # to add a hp printer via hplip
    hplip

    # nix
    nixd
    nixpkgs-fmt
    nix-tree

    efibootmgr
  ];

  # enable ssh, so in the case of display failure, i can still access the machine
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
    };
    openFirewall = true;
  };

  programs.zsh.enable = true;
  programs.command-not-found.enable = false;
  programs.nix-index-database.comma.enable = true;

  # Firmware updates
  services.fwupd.enable = true;

  # Filesystems
  boot.supportedFilesystems = [
    "ntfs"
  ];

  # resolved for wireguard
  services.resolved.enable = true;
  services.fstrim.enable = true;

  # enable remote building to raspi
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # cron job for automatic repo updates
  services.cron = {
    enable = true;
    systemCronJobs = [
      "0 */2 * * *      root    cd /home/elias/NyxOS && ./update.sh >> /var/log/nixos-update.log 2>&1"
    ];
  };

  # different kernels
  # fast
  boot.kernelPackages = pkgs.linuxPackages_zen;
  # leaning fast
  # boot.kernelPackages = pkgs.linuxPackages_lqx;
  # leaning stable
  # boot.kernelPackages = pkgs.linuxPackages_xanmod;
  # stable
  # boot.kernelPackages = pkgs.linuxPackages;

}
