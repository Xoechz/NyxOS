{ inputs, ... }: {
  flake-file.inputs = {
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };
  };

  # System Module flatpak: enable flatpak and add flathub repo
  flake.modules.nixos.flatpak = { pkgs, ... }: {
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

  # Home Module defaultApplicationsKde: set default applications for kde
  flake.modules.homeManager.defaultApplicationsKde = { ... }: {
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/file" = "org.kde.dolphin.desktop";
      };
    };
  };

  # Home Module libreoffice: configure libreoffice with basic settings
  flake.modules.homeManager.libreoffice = { pkgs, ... }: {
    home.packages = with pkgs; [
      libreoffice-qt
      hunspell
      hunspellDicts.en_US
      hunspellDicts.de_AT
    ];
  };

  # Home Module email: configure email clients
  flake.modules.homeManager.email = { pkgs, ... }: {
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

  # Home Module teams: configure microsoft teams client
  flake.modules.homeManager.teams = { pkgs, ... }: {
    home.packages = with pkgs; [
      teams-for-linux
    ];
  };

  # Home Module pdf: configure pdf related tools
  flake.modules.homeManager.pdf = { pkgs, ... }: {
    home.packages = with pkgs; [
      pdfarranger
      kdePackages.okular
    ];
  };

  # Home Module media: configure media players
  flake.modules.homeManager.media = { pkgs, ... }: {
    imports = [ inputs.spicetify-nix.homeManagerModules.default ];

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

  # Home Module discord: configure discord with vencord
  flake.modules.homeManager.discord = { pkgs, ... }: {
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

  # Home Module kdeConnect: configure kdeconnect for home manager
  flake.modules.homeManager.kdeConnect = { pkgs, ... }: {
    home.packages = with pkgs; [
      kdePackages.kdeconnect-kde
    ];
  };

  # Home module obs: configure obs studio
  flake.modules.homeManager.obs = { pkgs, ... }: {
    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
      ];
    };
  };

  # Home Module vscode: configure vscode for home manager
  flake.modules.homeManager.vscode = { pkgs, ... }: {
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

  # Home Module qgis: configure qgis for home manager
  flake.modules.homeManager.qgis = { pkgs, ... }: {
    home.packages = with pkgs; [
      qgis
    ];
  };

  # Home module mediaEditors: configure media editors
  flake.modules.homeManager.mediaEditors = { pkgs, pkgs-stable, ... }: {
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
