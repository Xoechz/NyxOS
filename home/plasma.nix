# my prefered plasma config
{ ... }:
{
  programs.plasma = {
    enable = true;
    overrideConfig = false;
    input = {
      keyboard = {
        model = "pc105";
        switchingPolicy = "global";
        layouts = [
          {
            layout = "at";
          }
        ];
        numlockOnStartup = "unchanged";
        repeatDelay = 600;
        repeatRate = 25;
      };
    };
    kscreenlocker = {
      autoLock = true;
      lockOnResume = true;
      timeout = 30;
      passwordRequired = true;
      passwordRequiredDelay = 5;
      lockOnStartup = false;
      appearance = {
        alwaysShowClock = true;
        showMediaControls = true;
        wallpaper = "/home/elias/NyxOS/nixos-wallpaper-catppuccin-mocha.png";
      };
    };
    kwin = {
      # Disables the edge-barriers introduced in plasma 6.1
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
    panels = [
      {
        # "Taskbar"
        location = "left";
        height = 44;
        lengthMode = "fit";
        alignment = "left";
        hiding = "none";
        floating = false;
        screen = "all";
        widgets = [
          "org.kde.plasma.showdesktop"
          {
            iconTasks = {
              launchers = [
                "applications:org.kde.konsole.desktop"
                "applications:org.kde.dolphin.desktop"
                "applications:thunderbird.desktop"
                "applications:firefox.desktop"
                "applications:code.desktop"
                "applications:steam.desktop"
                "applications:discord.desktop"
              ];
              appearance = {
                showTooltips = true;
                highlightWindows = true;
                indicateAudioStreams = true;
                fill = true;
                rows = {
                  multirowView = "never";
                };
                iconSpacing = "medium";
              };
              behavior = {
                grouping = {
                  method = "byProgramName";
                  clickAction = "cycle";
                };
                sortingMethod = "none";
                minimizeActiveTaskOnClick = true;
                middleClickAction = "newInstance";
                wheel = {
                  switchBetweenTasks = true;
                  ignoreMinimizedTasks = true;
                };
                showTasks = {
                  onlyInCurrentScreen = false;
                  onlyInCurrentDesktop = true;
                  onlyInCurrentActivity = true;
                  onlyMinimized = false;
                };
                unhideOnAttentionNeeded = true;
                newTasksAppearOn = "right";
              };
            };
          }
          "org.kde.plasma.pager"
          {
            kickoff = {
              icon = "nix-snowflake-white";
              sortAlphabetically = false;
              compactDisplayStyle = false;
              favoritesDisplayMode = "grid";
              applicationsDisplayMode = "list";
              showButtonsFor = "power";
              showActionButtonCaptions = true;
              pin = false;
              sidebarPosition = "right";
            };
          }
        ];
      }
      {
        # "System Tray"
        location = "right";
        height = 36;
        lengthMode = "fit";
        alignment = "left";
        hiding = "none";
        floating = false;
        screen = "all";
        widgets = [
          {
            name = "org.kde.plasma.lock_logout";
            config.General =
              {
                show_lockScreen = true;
                show_requestShutDown = true;
                show_requestLogout = true;
                show_requestReboot = true;
              };
          }
          {
            systemTray = {
              pin = false;
              icons = {
                spacing = "medium";
                scaleToFit = false;
              };
              items = {
                showAll = true;
                extra = [
                  "org.kde.plasma.volume"
                  "org.kde.plasma.networkmanagement"
                  "org.kde.plasma.bluetooth"
                  "org.kde.plasma.clipboard"
                  "org.kde.plasma.battery"
                  "org.kde.plasma.brighness"
                  "org.kde.plasma.displays"
                  "org.kde.plasma.mediacontroller"
                  "org.kde.plasma.notifications"
                  "org.kde.plasma.removabledevices"
                ];
              };
            };
          }
          {
            digitalClock = {
              date = {
                enable = true;
                format.custom = "dd.MM";
                position = "belowTime";
              };
              time = {
                showSeconds = "onlyInTooltip";
                format = "24h";
              };
              timeZone = {
                selected = [ "Local" ];
                format = "code";
                alwaysShow = false;
              };
            };
          }
        ];
      }
    ];
    spectacle.shortcuts = {
      captureActiveWindow = "Meta+Print";
      captureCurrentMonitor = "Print";
      captureEntireDesktop = "Shift+Print";
      captureRectangularRegion = "Meta+Shift+S";
      captureWindowUnderCursor = "Meta+Ctrl+Print";
      launch = "Meta+S";
      launchWithoutCapturing = "Meta+Alt+S";
      recordRegion = "Meta+Shift+R";
      recordScreen = "Meta+Alt+R";
      recordWindow = "Meta+Ctrl+R";
    };
    windows = {
      allowWindowsToRememberPositions = true;
    };
    workspace = {
      wallpaper = "/home/elias/NyxOS/nixos-wallpaper-catppuccin-mocha.png";
      iconTheme = "Papirus";
      theme = "breeze-dark";
      colorScheme = "CatppuccinMochaFlamingo";
      soundTheme = "ocean";
      splashScreen = {
        theme = "None";
      };
    };
  };
}
