{ inputs, ... }: {
  flake-file.inputs = {
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  # System Module kde
  flake.modules.nixos.kde = { pkgs, ... }: {
    # Enable the X11 windowing system. Disabling it seems to break a lot of stuff.
    services.xserver.enable = true;

    # Enable libinput for X11 (essential for keyboard/mouse on X11)
    services.libinput.enable = true;

    # Ensure X11 input drivers are available
    services.xserver.modules = [ pkgs.xorg.xf86inputlibinput ];

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "at";
    };

    # Enable the KDE Plasma Desktop Environment.
    services.desktopManager.plasma6.enable = true;

    # Use Plasma X11 for better compatibility with older hardware
    services.displayManager = {
      defaultSession = "plasmax11";
      sddm = {
        enable = true;
        wayland.enable = false;
      };
    };

    # exclude some packages
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      kate
      khelpcenter
      konsole
      elisa
    ];

    environment.systemPackages = with pkgs; [
      kdePackages.kwin-x11
    ];
  };

  # Home Module plasma-manager: configure plasma manager
  flake.modules.homeManager.plasma-manager = { ... }: {
    imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

    # for this to work the plasma drawer widget, the papirus icon theme and the catppuccin mocha flamingo color scheme have to be downloaded manually
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
