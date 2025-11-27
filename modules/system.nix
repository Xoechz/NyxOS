{ pkgs, ... }:
{
  nix.settings = {
    substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos.org/"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

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
    trusted-users = [ "elias" "nixremote" ];
  };

  users.users.elias.shell = pkgs.zsh;

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
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
    };
    openFirewall = true;
  };

  programs.zsh.enable = true;

  # Firmware updates
  services.fwupd.enable = true;

  # Filesystems
  boot.supportedFilesystems = [
    "ntfs"
  ];

  # resolved for wireguard
  services.resolved.enable = true;

  # enable remote building to raspi
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # cron job for automatic repo updates
  services.cron = {
    enable = true;
    systemCronJobs = [
      "0 */2 * * *      root    cd /home/elias/NyxOS && ./update.sh >> /var/log/nixos-update.log 2>&1"
    ];
  };
}
