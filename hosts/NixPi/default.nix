# The system config base for EliasPC
{ pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;

  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.hostName = "NixPi";

  # Enable networking
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Vienna";

  # swap
  zramSwap.enable = true;
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 8 * 1024; # 8GB
    randomEncryption.enable = true;
  }];

  # user setup
  users.users.elias = {
    isNormalUser = true;
    description = "Elias";
    # lpadmin is needed for printer setup
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # enable flakes and new nix commands
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "elias" "nixremote" ];
  };

  nix.settings = {
    substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos.org/"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

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

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      # SSH
      22
      # HTTP
      80
      # HTTPS
      443
      # DNS
      53
    ];
    allowedUDPPorts = [
      # DNS
      53
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

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
      PasswordAuthentication = true;
    };
    openFirewall = true;
  };

  # Firmware updates
  services.fwupd.enable = true;

  environment.systemPackages = with pkgs; [
    fastfetch
    wget
    curl
    openssl
  ];

  services.blocky = {
    enable = true;
    settings = {
      ports.dns = 53; # Port for incoming DNS Queries.
      upstreams.groups.default = [
        "https://one.one.one.one/dns-query" # Using Cloudflare's DNS over HTTPS server for resolving queries.
      ];
      # For initially solving DoH/DoT Requests when no system Resolver is available.
      bootstrapDns = {
        upstream = "https://one.one.one.one/dns-query";
        ips = [ "1.1.1.1" "1.0.0.1" ];
      };
      #Enable Blocking of certain domains.
      blocking = {
        denylists = {
          #Adblocking
          ads = [
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
            "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
            "https://blocklistproject.github.io/Lists/ads.txt"
            "https://blocklistproject.github.io/Lists/malware.txt"
            "https://blocklistproject.github.io/Lists/scam.txt"
          ];
        };
        # allowlist = {
        #   ads = [
        #     # add domains that should not be blocked here
        #   ];
        # };
        #Configure what block categories are used
        clientGroupsBlock = {
          default = [ "ads" ];
        };
      };
      customDNS = {
        customTTL = "1h";
        mapping = {
          "gateway.lan" = "192.168.0.1";
          "nixpi.lan" = "192.168.0.10";
          "printer.lan" = "192.168.0.11";
          "eliasPc.lan" = "192.168.0.12";
          "eliasLaptop.lan" = "192.168.0.13";
        };
      };
      caching = {
        minTime = "5m";
        maxTime = "30m";
        prefetching = true;
      };
    };
  };

  system.stateVersion = "25.11";
}
