# The system config base for EliasPC
{ pkgs, ... }:

{
  imports =
    [
      ../../modules/language_en_at.nix
      ../../modules/build.nix
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

  # Create nixremote user for remote builds
  users.users.nixremote = {
    isSystemUser = true;
    group = "nixremote";
    home = "/var/lib/nixremote";
    createHome = true;
    shell = pkgs.zsh;
  };

  users.groups.nixremote = { };

  # Allow nixremote to run nix commands without password
  security.sudo.extraRules = [
    {
      users = [ "nixremote" ];
      commands = [
        {
          command = "${pkgs.nix}/bin/nix-store";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.nix}/bin/nix-daemon";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

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

  # Offload builds to EliasPC
  nix.distributedBuilds = true;

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
