# vscode and jetbrains programs.
{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
  };

  # jetbrains programs
  home.packages = with pkgs; [
    jetbrains.clion
  ];
}
