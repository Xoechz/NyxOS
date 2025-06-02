# vscode and jetbrains programs.
{ pkgs, pkgs-stable, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
  };

  home.packages = [
    # jetbrains programs
    # (pkgs-stable.jetbrains.plugins.addPlugins pkgs-stable.jetbrains.datagrip [ "github-copilot" ])
    (pkgs-stable.jetbrains.plugins.addPlugins pkgs-stable.jetbrains.idea-ultimate [ "github-copilot" ])

    # pkgs.qgis

    pkgs.inkscape
    pkgs.gimp

    pkgs.xidel
  ];
}
