# default home-manager config, could be split up in the future
{ pkgs, ... }:
{
  imports =
    [
      ./editors.nix
      ./office.nix
      ./media.nix
      ./plasma.nix
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
  ];

  #enable direnv
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  #setup git to use the correct email for commits
  programs.git = {
    enable = true;
    userName = "Elias Leonhardsberger";
    userEmail = "elias.leonhardsberger@gmail.com";
  };

  #enable bash completion, maybe in the future ill use another shell
  programs.bash = {
    enable = true;
    enableCompletion = true;
  };

  home.stateVersion = "24.05";

  programs.home-manager.enable = true;
}
