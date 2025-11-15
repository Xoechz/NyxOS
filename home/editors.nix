# varios editors
{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
  };

  home.packages = with pkgs; [
    # pkgs.qgis

    inkscape
    gimp
    kdePackages.kdenlive
  ];
}
