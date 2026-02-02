{ ... }:

{
  imports =
    [
      ./default.nix
      ./styling.nix
      ./terminal.nix
    ];

  home.username = "elias";
  home.homeDirectory = "/home/elias";
}
