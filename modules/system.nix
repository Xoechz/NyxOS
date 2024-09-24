# The base system config
{ pkgs, ... }:
{
  # user setup
  users.users.elias = {
    isNormalUser = true;
    description = "Elias";
    extraGroups = [ "networkmanager" "wheel" ];
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
  i18n.defaultLocale = "en_US.UTF-8";

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
    LANGUAGE = "en_US.UTF-8";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;

  #configure pipewire
  services = {
    dbus.packages = [ pkgs.gcr ];

    geoclue2.enable = true;
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
    # Ports for HTTP, HTTPS, SSH, Stardew Valley and Steam Local Network Game Transfer
    allowedTCPPorts = [ 22 80 443 57621 27040 ];
    allowedUDPPorts = [ 5353 24642 27031 27032 27033 27034 27035 27036 ];
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
    baobab

    iptables

    gnome-multi-writer
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
}
