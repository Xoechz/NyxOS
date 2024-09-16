# vscode and jetbrains programs.
{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
  };

  home.packages = with pkgs; [
    # jetbrains programs
    jetbrains.clion
    jetbrains.datagrip

    qgis
  ];
}
