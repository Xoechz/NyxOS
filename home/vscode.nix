{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      ms-dotnettools.csdevkit
      ms-dotnettools.csharp
      ms-dotnettools.vscodeintellicode-csharp
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
}
