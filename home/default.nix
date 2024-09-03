# default home-manager config, could be split up in the future
{ pkgs, ... }:
{
  imports =
    [
      ./editors.nix
      ./office.nix
      ./media.nix
      ./plasma.nix
      ./games.nix
      ./defaultApplications.nix
      ./styling.nix
      ./terminal.nix
    ];

  home.username = "elias";
  home.homeDirectory = "/home/elias";

  home.packages = with pkgs; [
    ripgrep
    fzf

    mtr
    iperf3
    dnsutils

    which
    tree

    nix-output-monitor

    btop
    iotop
    iftop

    strace
    ltrace
    lsof

    ethtool
    pciutils
    usbutils

    tor-browser
    transmission_4-qt
    wireguard-tools
    kdePackages.kdeconnect-kde
  ];

  #setup git to use the correct email for commits
  programs.git = {
    enable = true;
    userName = "Elias Leonhardsberger";
    userEmail = "elias.leonhardsberger@gmail.com";
  };

  home.stateVersion = "24.05";

  programs.home-manager.enable = true;
}
