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
        wallpaper = "/home/elias/NyxOS/images/nixos-wallpaper-catppuccin-mocha.png";
        alwaysShowClock = true;
        showMediaControls = true;
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
        # Taskbar
        location = "top";
        height = 32;
        lengthMode = "fill";
        alignment = "center";
        hiding = "none";
        floating = false;
        screen = "all";
        widgets = [
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
          "org.kde.plasma.pager"
          {
            iconTasks = {
              launchers = [
                "applications:kitty.desktop"
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
          "org.kde.plasma.marginsseparator" # Spacer to Right
          {
            digitalClock = {
              date = {
                enable = true;
                format.custom = "dd.MM.yyyy";
                position = "belowTime";
              };
              time = {
                showSeconds = "always";
                format = "24h";
              };
              timeZone = {
                selected = [ "Local" ];
                format = "code";
                alwaysShow = false;
              };
            };
          }
          {
            systemTray = {
              pin = false;
              icons = {
                spacing = "small";
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
                  "org.kde.kdeconnect"
                ];
              };
            };
          }
          {
            # lock
            name = "org.kde.plasma.lock_logout";
            config.General =
              {
                show_lockScreen = true;
                show_requestShutDown = false;
                show_requestLogout = false;
                show_requestReboot = false;
              };
          }
          {
            # logout
            name = "org.kde.plasma.lock_logout";
            config.General =
              {
                show_lockScreen = false;
                show_requestShutDown = false;
                show_requestLogout = true;
                show_requestReboot = false;
              };
          }
          {
            # reboot
            name = "org.kde.plasma.lock_logout";
            config.General =
              {
                show_lockScreen = false;
                show_requestShutDown = false;
                show_requestLogout = false;
                show_requestReboot = true;
              };
          }
          {
            # shutdown
            name = "org.kde.plasma.lock_logout";
            config.General =
              {
                show_lockScreen = false;
                show_requestShutDown = true;
                show_requestLogout = false;
                show_requestReboot = false;
              };
          }
          {
            plasmaPanelColorizer = {
              general = {
                enable = true;
                hideWidget = true;
              };
              panelBackground.originalBackground.hide = true;
              layout.widgetMarginRules = [
                {
                  widgetId = "org.kde.plasma.kickoff";
                  margin = {
                    vertical = -9;
                    horizontal = 0;
                  };
                }
                {
                  widgetId = "org.kde.plasma.icontasks";
                  margin = {
                    vertical = -8;
                    horizontal = -5;
                  };
                }
                {
                  widgetId = "org.kde.plasma.systemtray";
                  margin = {
                    vertical = 0;
                    horizontal = -5;
                  };
                }
                {
                  widgetId = "org.kde.plasma.lock_logout";
                  margin = {
                    vertical = 1;
                    horizontal = 1;
                  };
                }
              ];
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
      iconTheme = "Papirus";
      wallpaper = "/home/elias/NyxOS/images/nixos-wallpaper-catppuccin-mocha.png";
      colorScheme = "CatppuccinMochaFlamingo";
      soundTheme = "ocean";
      splashScreen = {
        theme = "None";
      };
    };
  };
}
