{ ... }:

{
  imports =
    [
      ./default.nix
      ./editors.nix
      ./office.nix
      ./defaultApplications.nix
      ./terminal.nix
    ];

  home.username = "fred";
  home.homeDirectory = "/home/fred";
}
