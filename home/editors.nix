# varios editors
{ pkgs, pkgs-stable, ... }:

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
  ] ++ [
    pkgs-stable.kdePackages.kdenlive
  ];
}
