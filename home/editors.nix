# vscode with all extensions for nix development and jetbrains programs. New extensions need be be installed via this config
{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      # ms-dotnettools.csdevkit
      # ms-dotnettools.csharp
      # ms-dotnettools.vscodeintellicode-csharp
      visualstudioexptteam.vscodeintellicode
      ms-vscode.cpptools
      ms-vscode.cmake-tools
      mhutchie.git-graph
      github.copilot
      github.copilot-chat
      bierner.markdown-mermaid
      davidanson.vscode-markdownlint
      arrterian.nix-env-selector
      jnoortheen.nix-ide
      emmanuelbeziat.vscode-great-icons
      tomoki1207.pdf
      mkhl.direnv
    ];
  };

  # jetbrains programs
  home.packages = with pkgs; [
    jetbrains.clion
  ];
}
