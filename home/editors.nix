# vscode and jetbrains programs.
{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
  };

  home.packages = with pkgs; [
    # jetbrains programs
    (jetbrains.plugins.addPlugins jetbrains.datagrip [ "github-copilot" ])

    # qgis

    inkscape
  ];

}
