# default home-manager config, could be split up in the future
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ripgrep
    fzf

    mtr
    iperf3
    dnsutils

    which
    tree
    iotop
    iftop

    baobab

    strace
    ltrace
    lsof
    traceroute

    ethtool
    pciutils
    usbutils

    hdparm

    ntfs3g
    exfat

    dmidecode

    parallel
    libwebp

    jq

    vlc
  ];

  #setup git to use the correct email for commits
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Elias Leonhardsberger";
        email = "elias.leonhardsberger@gmail.com";
      };
      alias = {
        graph = "log --decorate --oneline --graph --max-count=20";
      };
      pull.rebase = true;
      core.autocrlf = "input";
    };
    lfs.enable = true;
  };

  services.home-manager = {
    autoExpire = {
      enable = true;
      frequency = "monthly";
      timestamp = "-30 days";
    };
  };

  home.stateVersion = "24.05";

  programs.home-manager.enable = true;
}
