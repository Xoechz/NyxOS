{ config, pkgs, ... }:

{
  programs.vscode = {
  enable = true;
  extensions = with pkgs.vscode-extensions; [
    ms-dotnettools.csdevkit
    ms-dotnettools.csharp
    ms-dotnettools.vscodeintellicode-csharp
    discretegames.f5anything
    mhutchie.git-graph
    GitHub.copilot
    GitHub.copilot-chat
    bierner.markdown-mermaid
    DavidAnson.vscode-markdownlint
    arrterian.nix-env-selector
    jnoortheen.nix-ide
    emmanuelbeziat.vscode-great-icons
    tomoki1207.pdf
    tonybaloney.vscode-pets
    mkhl.direnv
  ];
};
}