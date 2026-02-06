{ pkgs, pkgs-stable, inputs, ... }: {
  flake-file.inputs = {
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };
  };

  # Module flatpack: enable flatpak and add flathub repo
  flake.modules.nixos.flatpak = {
    services.flatpak.enable = true;
    systemd.services.flatpak-repo = {
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.flatpak ];
      script = ''
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      '';
    };

    environment.systemPackages = with pkgs; [
      kdePackages.discover
    ];
  };

  # Module defaultApplicationsKde: set default applications for kde
  flake.modules.home-manager.defaultApplicationsKde = {
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/file" = "org.kde.dolphin.desktop";
      };
    };
  };

  # Module libreoffice: configure libreoffice with basic settings
  flake.modules.home-manager.libreoffice = {
    home.packages = with pkgs; [
      libreoffice-qt
      hunspell
      hunspellDicts.en_US
      hunspellDicts.de_AT
    ];
  };

  # Module email: configure email clients
  flake.modules.home-manager.email = {
    home.packages = with pkgs; [
      thunderbird
    ];

    xdg.mimeApps = {
      defaultApplications = {
        "x-scheme-handler/mailto" = "thunderbird.desktop";
        "text/calendar" = "thunderbird.desktop";
        "message/rfc822" = "thunderbird.desktop";
        "application/x-extension-ics" = "thunderbird.desktop";
      };
      associations.added = {
        "x-scheme-handler/mailto" = "thunderbird.desktop";
        "x-scheme-handler/mid" = "thunderbird.desktop";
        "x-scheme-handler/webcal" = "thunderbird.desktop";
        "x-scheme-handler/webcals" = "thunderbird.desktop";
      };
    };
  };

  # Module teams: configure microsoft teams client
  flake.modules.home-manager.teams = {
    home.packages = with pkgs; [
      teams-for-linux
    ];
  };

  # Module pdf: configure pdf related tools
  flake.modules.home-manager.pdf = {
    home.packages = with pkgs; [
      pdfarranger
      kdePackages.okular
    ];
  };

  # Module media: configure media players
  flake.modules.home-manager.media = {
    home.packages = with pkgs; [
      cava
      vlc
    ];

    programs.spicetify =
      let
        spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
      in
      {
        enable = true;

        enabledExtensions = with spicePkgs.extensions; [
          shuffle # shuffle+ (special characters are sanitized out of extension names)
          playlistIcons
          fullAlbumDate
          wikify
          songStats
          betterGenres
          playNext
          volumePercentage
        ];

        theme = spicePkgs.themes.catppuccin;
        colorScheme = "mocha";
      };
  };

  # Module discord: configure discord with vencord
  flake.modules.home-manager.discord = {
    home.packages = with pkgs; [
      (discord.override {
        withVencord = true;
      })
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
  };

  # Module kdeConnect: configure kdeconnect for home manager
  flake.modules.home-manager.kdeConnect = {
    home.packages = with pkgs; [
      kdePackages.kdeconnect-kde
    ];
  };

  # module obs: configure obs studio
  flake.modules.home-manager.obs = {
    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
      ];
    };
  };

  # module vscode: configure vscode for home manager
  flake.modules.home-manager.vscode = {
    programs.vscode = {
      enable = true;
      package = pkgs.vscode.fhs;
    };

    xdg.mimeApps = {
      defaultApplications = {
        "text/plain" = "code.desktop";
      };
      associations.added = {
        "inode/directory" = "code.desktop";
      };
    };
  };

  # module qgis: configure qgis for home manager
  flake.modules.home-manager.qgis = {
    home.packages = with pkgs; [
      qgis
    ];
  };

  # module mediaEditors: configure media editors
  flake.modules.home-manager.mediaEditors = {
    home.packages = with pkgs; [
      inkscape
      adwaita-icon-theme
      gimp
    ] ++ [
      pkgs-stable.kdePackages.kdenlive
    ];

    xdg.mimeApps.defaultApplications = {
      "image/svg" = "inkscape.desktop";
    };
  };
}
