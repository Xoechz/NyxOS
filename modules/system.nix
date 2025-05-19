# The base system config
#{ pkgs, pkgs-stable, ... }:
{ pkgs, ... }:
{
  # user setup
  users.users.elias = {
    isNormalUser = true;
    description = "Elias";
    # lpadmin is needed for printer setup
    extraGroups = [ "networkmanager" "wheel" "lpadmin" ];
  };

  # enable flakes and new nix commands
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "elias" ];
    substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos.org/"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Vienna";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_AT.UTF-8";
    LC_IDENTIFICATION = "de_AT.UTF-8";
    LC_MEASUREMENT = "de_AT.UTF-8";
    LC_MONETARY = "de_AT.UTF-8";
    LC_NAME = "de_AT.UTF-8";
    LC_NUMERIC = "de_AT.UTF-8";
    LC_PAPER = "de_AT.UTF-8";
    LC_TELEPHONE = "de_AT.UTF-8";
    LC_TIME = "de_AT.UTF-8";
    LANGUAGE = "en_GB.UTF-8";
    LANG = "en_GB.UTF-8";
    LC_ALL = "en_GB.UTF-8";
  };

  # Install firefox.
  programs.firefox = {
    enable = true;
    #package = pkgs-stable.firefox;
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
      # Steam Local Network Game Transfer
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
    ];
    allowedTCPPortRanges = [
      # KDE Connect
      { from = 1714; to = 1764; }
    ];
    allowedUDPPortRanges = [
      # KDE Connect
      { from = 1714; to = 1764; }
      # Steam Local Network Game Transfer
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
    glxinfo

    wayland-utils
    gparted

    openssl

    iptables
    inetutils

    gnome-multi-writer

    # to add a hp printer via hplip
    hplip
  ];

  # garbage collection to save diskspace
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nix.optimise = {
    automatic = true;
  };

  # enable ssh, so in the case of display failure, i can still access the machine
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
    openFirewall = true;
  };

  users.users.elias.shell = pkgs.zsh;
  programs.zsh.enable = true;

  # Firmware updates
  services.fwupd.enable = true;

  # Filesystems
  boot.supportedFilesystems = [
    "ntfs"
  ];

  # resolved for wireguard
  services.resolved.enable = true;

  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };

  # swap
  zramSwap.enable = true;
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 32 * 1024; # 32GB
    randomEncryption.enable = true;
  }];

  # latest kernel release
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
