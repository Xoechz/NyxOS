{ pkgs, ... }:

{
  imports =
    [
      ./vscode.nix
      ./libreoffice.nix
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

    thunderbird
  ];

  programs.git = {
    enable = true;
    userName = "Elias Leonhardsberger";
    userEmail = "elias.leonhardsberger@gmail.com";
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
  };

  home.stateVersion = "24.05";

  programs.home-manager.enable = true;
}
