# vscode and jetbrains programs.
{ pkgs, pkgs-stable, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
  };

  home.packages = with pkgs; [
    # jetbrains programs
    # (pkgs-stable.jetbrains.plugins.addPlugins pkgs-stable.jetbrains.datagrip [ "github-copilot" ])
    (pkgs-stable.jetbrains.plugins.addPlugins pkgs-stable.jetbrains.idea-ultimate [ "github-copilot" ])

    # pkgs.qgis

    inkscape
    gimp
    kdePackages.kdenlive
  ];
}
