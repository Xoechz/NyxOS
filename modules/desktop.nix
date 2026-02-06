{ inputs, pkgs, ... }: {
  flake-file.inputs = {
    catppuccin.url = "github:catppuccin/nix";
  };

  # Module languageEn
  flake.modules.nixos.languageEn = {
    i18n.defaultLocale = "en_GB.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "de_AT.UTF-8";
      LC_IDENTIFICATION = "de_AT.UTF-8";
      LC_MEASUREMENT = "de_AT.UTF-8";
      LC_MONETARY = "de_AT.UTF-8";
      LC_NAME = "de_AT.UTF-8";
      LC_NUMERIC = "de_AT.UTF-8";
      LC_PAPER = "de_AT.UTF-8";
      LC_TELEPHONE = "de_AT.UTF-8";
      LC_TIME = "de_AT.UTF-8";
      LANGUAGE = "en_GB.UTF-8";
      LANG = "en_GB.UTF-8";
      LC_ALL = "en_GB.UTF-8";
    };
  };

  # Module languageDe
  flake.modules.nixos.languageDe = {
    i18n.defaultLocale = "de_AT.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "de_AT.UTF-8";
      LC_IDENTIFICATION = "de_AT.UTF-8";
      LC_MEASUREMENT = "de_AT.UTF-8";
      LC_MONETARY = "de_AT.UTF-8";
      LC_NAME = "de_AT.UTF-8";
      LC_NUMERIC = "de_AT.UTF-8";
      LC_PAPER = "de_AT.UTF-8";
      LC_TELEPHONE = "de_AT.UTF-8";
      LC_TIME = "de_AT.UTF-8";
      LANGUAGE = "de_AT.UTF-8";
      LANG = "de_AT.UTF-8";
      LC_ALL = "de_AT.UTF-8";
    };
  };

  # Module basicFonts
  flake.modules.nixos.basicFonts = {
    fonts = {
      packages = with pkgs;[
        # JetBrains officially created font for developers
        nerd-fonts.jetbrains-mono
        # `0` and `O` very similar, characters are either very curvy or straight lined
        nerd-fonts.noto
      ];

      enableDefaultPackages = true;
      enableGhostscriptFonts = true;
      fontconfig.defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" ];
      };
    };
  };

  # Module fonts
  flake.modules.nixos.fonts = {
    fonts = {
      packages = with pkgs;[
        corefonts
        vista-fonts

        # Nerd Fonts
        # A programming font focused on source code legibility
        nerd-fonts._0xproto
        # Derived from the x3270 font, a modern format of a font with high nostalgic value
        nerd-fonts._3270
        # The monospace typeface for GNOME
        nerd-fonts.adwaita-mono
        # A small, monospace, outline font that is geometrically regular and simple
        nerd-fonts.agave
        # Inspired by Anonymous 9 on Macintosh, since 2009, distinct `O`, `0`, `I`, `l`, `1`
        nerd-fonts.anonymice
        # Metrically similar to Arial, pan-European WGL character set, sans serif
        nerd-fonts.arimo
        # A monospaced font designed to improve legibility and readability for individuals with low vision
        nerd-fonts.atkynson-mono
        # Sans serif, designed by Stephen G. Hartke which also created Verily Serif
        nerd-fonts.aurulent-sans-mono
        # Nostalgic, closely based on IBM's 8x14 EGA/VGA charset
        nerd-fonts.bigblue-terminal
        # Dotted zero, compact lowercase characters
        nerd-fonts.bitstream-vera-sans-mono
        # It's global, it's versatile and it's distinctly IBM
        nerd-fonts.blex-mono
        # A fun, new monospaced font that includes programming ligatures and is designed to enhance the modern look and feel of the Windows Terminal
        nerd-fonts.caskaydia-cove
        # Like Cascadia Code but without any ligatures
        nerd-fonts.caskaydia-mono
        # Tunable, slashed zeros, compact smaller characters
        nerd-fonts.code-new-roman
        # The very typeface you’ve been trained to recognize since childhood
        nerd-fonts.comic-shanns-mono
        # An anonymous and neutral programming typeface
        nerd-fonts.commit-mono
        # Similar to Courier New with better readablitiy, dotted zeros
        nerd-fonts.cousine
        # A coding font for Koreans. This is the variant with ligatures.
        nerd-fonts.d2coding
        # A monospaced font for programmers and other terminal groupies
        nerd-fonts.daddy-time-mono
        # Dotted zero, based on the Bitstream Vera Fonts with a wider range of character
        nerd-fonts.dejavu-sans-mono
        # A monospaced pixel font with a lo-fi, techy vibe
        nerd-fonts.departure-mono
        # Good for small screens or font sizes
        nerd-fonts.droid-sans-mono
        # Fully-scalable monospaced font designed for programming and command prompts
        nerd-fonts.envy-code-r
        # \
        nerd-fonts.fantasque-sans-mono
        # Programming ligatures, extension of Fira Mono font, enlarged operators
        nerd-fonts.fira-code
        # Mozilla typeface, dotted zero
        nerd-fonts.fira-mono
        # Monospaced typeface designed to be used in code editors, diagrams, terminals, and other textbased interfaces where code is represented
        nerd-fonts.geist-mono
        # Created specifically for the Go project, looks particularly clear for use with the Go language
        nerd-fonts.go-mono
        # Bitmap font, tall capitals and ascenders, small serifs
        nerd-fonts.gohufont
        # Dotted zero, short descenders, expands upon work done for Bitstream Vera & DejaVu, legible at common sizes
        nerd-fonts.hack
        # Monospaced ligatures, makes composite glyphs (e.g. ->) more reabable, especially in Haskell
        nerd-fonts.hasklug
        # Novel and unique design, dotted zero
        nerd-fonts.heavy-data
        # Symbols stand out from common text
        nerd-fonts.hurmit
        # A heavy modification of IBM's Plex font
        nerd-fonts.im-writing
        # Slashed zero, takes inspiration from many different fonts and glyphs, subtle curves in lowercase
        nerd-fonts.inconsolata
        # Expressive monospaced font family that’s built with clarity, legibility, and the needs of developers in mind
        nerd-fonts.intone-mono
        # Narrow and horizontally tight characters, slashed zero
        nerd-fonts.iosevka
        # JetBrains officially created font for developers
        nerd-fonts.jetbrains-mono
        # Very light and thin characters, sharp m's, `0` and `O` very similar
        nerd-fonts.lekton
        # `0` and `O` very similar, very short tight descenders
        nerd-fonts.liberation
        # Modern with ligatures
        nerd-fonts.lilex
        # Free and open-source monospaced font from Evil Martians
        nerd-fonts.martian-mono
        # Slashed zeros, customized version of Apple's Menlo
        nerd-fonts.meslo-lg
        # Five matching fonts all having 'texture healing' to improve legibility
        nerd-fonts.monaspace
        # Dotted zeros, slightly exaggerated curvy characters, compact characters
        nerd-fonts.monofur
        # Ligatures, distinguishable glyphs with short ascenders & descenders, large operators & punctuation
        nerd-fonts.monoid
        # Keeps in mind differentiation of characters and resolution sizes
        nerd-fonts.mononoki
        # `0` and `O` very similar, characters are either very curvy or straight lined
        nerd-fonts.noto
        # Designed specifically to alleviate reading errors caused by dyslexia
        nerd-fonts.open-dyslexic
        # An open source font family inspired by Highway Gothic
        nerd-fonts.overpass
        # Looks best with anti-aliasing turned off, squared off character corners, vertically tight small `s`
        nerd-fonts.profont
        # Designed particularly for use at small point sizes
        nerd-fonts.proggy-clean-tt
        # inspired by casual script signpainting, 4 variants
        nerd-fonts.recursive-mono
        # Dashed zero, curved and straight character lines
        nerd-fonts.roboto-mono
        # Dotted zeros, distinguishable 1 and l, curved and straight character lines
        nerd-fonts.shure-tech-mono
        # Monospaced font family for user interface and coding environments
        nerd-fonts.sauce-code-pro
        # Squarish character lines, dotted zero, aggressive parethesis
        nerd-fonts.space-mono
        # Just the Nerd Font Icons. I.e Symbol font only
        nerd-fonts.symbols-only
        # Squarish characters that are slightly askew
        nerd-fonts.terminess-ttf
        # Some similarities to Times New Roman, designed by Steve Matteson, includes pan-European WGL character set
        nerd-fonts.tinos
        # Refreshed version of Ubuntu and Ubuntu Mono fonts
        nerd-fonts.ubuntu-sans
        # Clean, crisp and narrow, with a large x-height and clear punctuation
        nerd-fonts.victor-mono
        # Zed Mono is a more rounded version of Iosevka
        nerd-fonts.zed-mono
      ];

      enableDefaultPackages = true;
      enableGhostscriptFonts = true;
      fontconfig.defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" ];
      };
    };
  };

  # Module catppuccin: configure catppuccin theming
  flake.modules.nixos.catppuccin = {
    imports = [ inputs.catppuccin.modules.nixos.catppuccin ];

    catppuccin = {
      enable = true;
      flavor = "mocha";
      accent = "pink";
    };

    home-manager.sharedModules = [
      inputs.self.modules.homeManager.cattpuccinHome
    ];
  };

  # Module catppuccinHome: configure catppuccin theming in home manager
  flake.modules.home-manager.catppuccinHome = {
    imports = [ inputs.catppuccin.modules.homeManager.catppuccin ];

    catppuccin = {
      enable = true;
      flavor = "mocha";
      accent = "pink";
      vscode.profiles.default.enable = false; # vscode setup is done non declaratively. Sorry!
    };
  };
}
