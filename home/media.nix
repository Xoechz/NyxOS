# Media and communication oriented apps and packages
{ pkgs, spicetify-nix, ... }:
{
  imports = [
    spicetify-nix.homeManagerModules.default
  ];

  home.packages = with pkgs; [
    (discord.override {
      withVencord = true;
    })

    # "multi-media" apps
    tor-browser
    transmission_4-qt
    wireguard-tools
    kdePackages.kdeconnect-kde

    cava
  ];

  xdg.configFile."Vencord/themes/custom.css".text = ''
    /**
    * @name Catppuccin Mocha
    * @author winston#0001
    * @authorId 505490445468696576
    * @version 0.2.0
    * @description 🎮 Soothing pastel theme for Discord
    * @website https://github.com/catppuccin/discord
    * @invite r6Mdz5dpFc
    * **/

    @import url("https://catppuccin.github.io/discord/dist/catppuccin-mocha.theme.css");
  '';

  # spicetify spices up spotify
  programs.spicetify =
    let
      spicePkgs = spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      enable = true;

      enabledExtensions = with spicePkgs.extensions; [
        adblock
        shuffle # shuffle+ (special characters are sanitized out of extension names)
        fullAppDisplay
        playlistIcons
        fullAlbumDate
        wikify
        songStats
        betterGenres
        playNext
        volumePercentage
      ];
      enabledCustomApps = with spicePkgs.apps; [
        ncsVisualizer
      ];

      theme = spicePkgs.themes.catppuccin;
      colorScheme = "mocha";
    };

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
    ];
  };
}
