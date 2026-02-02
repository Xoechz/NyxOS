{ pkgs, ... }:
{
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
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICTZwgrSgkHT3WWJYIIe+dSvArtbp5JFetu6WpR5KC9t elias@EliasPC"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL71xmI34J5TlOzo6z0M3kTpzUTB7jxqiEvkALg4bcC6 root@EliasPC"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII8x7bIB+Ai92GiQ/m6SzFdUODBW0chhmwC0OERjofTi elias@EliasLaptop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKDhjGdO4LZSBd21DrYSt1iJAC5f1kP1Q9yleTf9qZ7o root@EliasLaptop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKEkkeMQneWIvzI9mzolIl2nyzt7pnzHqlNfk4zDlPyw elias@NixPi"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKF/LtEbMhHudYUlzGlYi3gdO819/U5KC1aJ5XNSkRJi root@NixPi"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPTsxwG/oZFKPLTH1SBVewZnWUaFJs9F+2o2SttnNv2j elias@FredPC"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEWvZfUNVpUiiNM5ZWm7gExARtj/LXKADUGwnh/XuaNe root@FredPC"
    ];
  };

  # To generate SSH keys:#
  # elias:
  # ssh-keygen -t ed25519 -N ""
  # cat ~/.ssh/id_ed25519.pub

  # Create nixremote user for remote builds
  users.users.nixremote = {
    isSystemUser = true;
    group = "nixremote";
    home = "/var/lib/nixremote";
    createHome = true;
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICTZwgrSgkHT3WWJYIIe+dSvArtbp5JFetu6WpR5KC9t elias@EliasPC"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL71xmI34J5TlOzo6z0M3kTpzUTB7jxqiEvkALg4bcC6 root@EliasPC"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII8x7bIB+Ai92GiQ/m6SzFdUODBW0chhmwC0OERjofTi elias@EliasLaptop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKDhjGdO4LZSBd21DrYSt1iJAC5f1kP1Q9yleTf9qZ7o root@EliasLaptop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKEkkeMQneWIvzI9mzolIl2nyzt7pnzHqlNfk4zDlPyw elias@NixPi"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKF/LtEbMhHudYUlzGlYi3gdO819/U5KC1aJ5XNSkRJi root@NixPi"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPTsxwG/oZFKPLTH1SBVewZnWUaFJs9F+2o2SttnNv2j elias@FredPC"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEWvZfUNVpUiiNM5ZWm7gExARtj/LXKADUGwnh/XuaNe root@FredPC"
    ];
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

  # SSH known hosts for distributed builds
  programs.ssh.knownHosts = {
    EliasPC = {
      hostNames = [ "EliasPC" "EliasPC.local" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPBHAqDy+XbGANEjlFRgFu/KhiA1Y08RSekbArf/o/9H";
    };
    EliasLaptop = {
      hostNames = [ "EliasLaptop" "EliasLaptop.local" ];
      publicKey = "eliaslaptop ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEQVC/JIg4qiVV18O5p+nABWSrM6O4JRQPxY7XBUtQ+L";
    };
    FredPC = {
      hostNames = [ "FredPC" "FredPC.local" ];
      publicKey = "fredpc ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINO21u53GTTwxbOX+mmhuGVBHFX5kAOAgyeI06/NCblr";
    };
    NixPi = {
      hostNames = [ "NixPi" "NixPi.local" ];
      publicKey = "nixpi ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDyuYVNGKSrpwWacyBFdqPdFxRTNhu8bcmQ0sk8j786T";
    };
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
    nix-output-monitor
    nvd

    efibootmgr
    powertop
  ];

  # enable ssh, so in the case of display failure, i can still access the machine
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
      PubkeyAuthentication = true;
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

  services.system76-scheduler = {
    enable = true;
    settings.cfsProfiles.enable = true;
  };

  powerManagement.powertop.enable = false;
}
