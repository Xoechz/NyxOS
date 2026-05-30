{ inputs, ... }: {
  flake-file.inputs = {
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  # System Module kde: enable KDE Plasma 6 on X11 with SDDM, Austrian keyboard layout, and trimmed default packages
  flake.modules.nixos.kde = { pkgs, ... }: {
    # Enable the X11 windowing system. Disabling it seems to break a lot of stuff.
    services.xserver.enable = true;

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "at";
    };

    # Enable the KDE Plasma Desktop Environment.
    services.desktopManager.plasma6.enable = true;

    # set KDE to wayland
    services.displayManager = {
      defaultSession = "plasma";
      sddm = {
        enable = true;
        wayland.enable = false;
      };
    };

    services.xserver.displayManager.setupCommands = ''
      ${pkgs.xrandr}/bin/xrandr --output DisplayPort-0 --primary --output HDMI-A-1 --same-as DisplayPort-0
    '';

    # exclude some packages
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      kate
      khelpcenter
      konsole
      elisa
    ];
  };

  # Home Module plasma-manager: configure KWin, KRunner, screen locker, power settings, and session restore via plasma-manager
  flake.modules.homeManager.plasma-manager = { ... }: {
    imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

    programs.plasma = {
      enable = true;
      overrideConfig = false;
      krunner = {
        position = "center";
        activateWhenTypingOnDesktop = true;
        historyBehavior = "enableSuggestions";
      };
      kscreenlocker = {
        autoLock = true;
        lockOnResume = true;
        timeout = 30;
        passwordRequired = true;
        passwordRequiredDelay = 5;
        lockOnStartup = false;
      };
      kwin = {
        # Disable the edge-barriers introduced in plasma 6.1
        edgeBarrier = 0;
        cornerBarrier = false;
        nightLight = {
          enable = true;
          mode = "times";
          time = {
            morning = "06:00";
            evening = "18:00";
          };
          temperature = {
            day = 6500;
            night = 4000;
          };
          transitionTime = 30;
        };
      };
      powerdevil.AC = {
        dimDisplay.enable = false;
        autoSuspend.action = "nothing";
      };
      session.sessionRestore.restoreOpenApplicationsOnLogin = "startWithEmptySession";
      windows = {
        allowWindowsToRememberPositions = true;
      };
    };
  };
}
