{ inputs, ... }: {
  flake-file.inputs = {
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };
  };

  # System Module flatpak: enable Flatpak and register the Flathub repository
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

  # Home Module libreoffice: install LibreOffice Qt with English and German spell-check dictionaries
  flake.modules.homeManager.libreoffice = { pkgs-stable, ... }: {
    home.packages = with pkgs-stable; [
      libreoffice-qt
      hunspell
      hunspellDicts.en_US
      hunspellDicts.de_AT
    ];

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        # ODT
        "application/vnd.oasis.opendocument.text" = "libreoffice-writer.desktop";
        # ODS
        "application/vnd.oasis.opendocument.spreadsheet" = "libreoffice-calc.desktop";
        # ODP
        "application/vnd.oasis.opendocument.presentation" = "libreoffice-impress.desktop";
        # DOCX
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "libreoffice-writer.desktop";
        # XLSX
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "libreoffice-calc.desktop";
        # PPTX
        "application/vnd.openxmlformats-officedocument.presentationml.presentation" = "libreoffice-impress.desktop";
      };
    };
  };

  # Home Module email: install Thunderbird and register it as the default mail and calendar handler
  flake.modules.homeManager.email = { pkgs, lib, ... }: {
    home.packages = with pkgs; [
      thunderbird
    ];

    xdg.mimeApps = {
      enable = lib.mkDefault true;
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

  # Home Module teams: install Teams for Linux
  flake.modules.homeManager.teams = { pkgs, ... }: {
    home.packages = with pkgs; [
      teams-for-linux
    ];
  };

  # Home Module pdf: install Okular and pdfarranger for viewing and rearranging PDF files
  flake.modules.homeManager.pdf = { pkgs, ... }: {
    home.packages = with pkgs; [
      pdfarranger
      kdePackages.okular
    ];
  };

  # Home Module media: install VLC and cava, and configure Spicetify-themed Spotify with extensions
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
        wayland = false;

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

  # Home Module discord: install Vesktop with Catppuccin Mocha CSS theme
  flake.modules.homeManager.discord = { pkgs, ... }: {
    home.packages = with pkgs; [
      vesktop
    ];

    xdg.configFile."vesktop/themes/custom.css".text = ''
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

  # Home Module kde-connect: install KDE Connect for phone-desktop integration
  flake.modules.homeManager.kde-connect = { pkgs, ... }: {
    home.packages = with pkgs; [
      kdePackages.kdeconnect-kde
    ];
  };

  # Home Module obs: install OBS Studio with wlrobs and background-removal plugins
  flake.modules.homeManager.obs = { pkgs, ... }: {
    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
      ];
    };
  };

  # Home Module vscode: install VS Code (FHS wrapper) and set it as the default text editor
  flake.modules.homeManager.vscode = { pkgs, lib, ... }: {
    programs.vscode = {
      enable = true;
      package = pkgs.vscode.fhs;
    };

    xdg.mimeApps = {
      enable = lib.mkDefault true;
      defaultApplications = {
        "text/plain" = "code.desktop";
      };
      associations.added = {
        "inode/directory" = "code.desktop";
      };
    };
  };

  # Home Module vscode-non-fhs: install VS Code (non-FHS) and set it as the default text editor
  flake.modules.homeManager.vscode-non-fhs = { lib, ... }: {
    programs.vscode.enable = true;

    xdg.mimeApps = {
      enable = lib.mkDefault true;
      defaultApplications = {
        "text/plain" = "code.desktop";
      };
      associations.added = {
        "inode/directory" = "code.desktop";
      };
    };
  };

  # Home Module idea: install JetBrains IntelliJ IDEA
  flake.modules.homeManager.idea = { pkgs, ... }: {
    home.packages = with pkgs; [
      jetbrains.idea
    ];
  };

  # Home Module rider: install JetBrains Rider
  flake.modules.homeManager.rider = { pkgs, ... }: {
    home.packages = with pkgs; [
      jetbrains.rider
    ];
  };

  # Home Module qgis: install QGIS geographic information system
  flake.modules.homeManager.qgis = { pkgs, ... }: {
    home.packages = with pkgs; [
      qgis
    ];
  };

  # Home Module media-editors: install GIMP, Inkscape, and kdenlive for image and video editing
  flake.modules.homeManager.media-editors = { pkgs, pkgs-stable, lib, ... }: {
    home.packages = with pkgs; [
      inkscape
      adwaita-icon-theme
      gimp
    ] ++ [
      pkgs-stable.kdePackages.kdenlive
    ];

    xdg.mimeApps = {
      enable = lib.mkDefault true;
      defaultApplications = {
        "image/svg+xml" = "org.inkscape.Inkscape.desktop";
      };
    };
  };

  # Home Module nomacs: install Nomacs image viewer and register it as the default for common image formats
  flake.modules.homeManager.nomacs = { pkgs, ... }: {
    home.packages = with pkgs; [
      nomacs
    ];

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "image/png" = "org.nomacs.ImageLounge.desktop";
        "image/jpeg" = "org.nomacs.ImageLounge.desktop";
        "image/gif" = "org.nomacs.ImageLounge.desktop";
        "image/bmp" = "org.nomacs.ImageLounge.desktop";
        "image/webp" = "org.nomacs.ImageLounge.desktop";
      };
    };
  };
}
