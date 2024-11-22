# vscode and jetbrains programs.
{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
  };

  home.packages = with pkgs; [
    # jetbrains programs
    (pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.datagrip [ "github-copilot" ])

    qgis
  ];

}
