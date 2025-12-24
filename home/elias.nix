{ ... }:

{
  imports =
    [
      ./default.nix
      ./editors.nix
      ./office.nix
      ./media.nix
      ./plasma.nix
      ./games.nix
      ./defaultApplications.nix
      ./styling.nix
      ./terminal.nix
      ./betterfox.nix
    ];

  home.username = "elias";
  home.homeDirectory = "/home/elias";
}
