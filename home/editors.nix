# varios editors
{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
  };

  home.packages = with pkgs; [
    pkgs.qgis

    # inkscape + icons
    inkscape
    adwaita-icon-theme

    gimp
    kdePackages.kdenlive
  ];
}
