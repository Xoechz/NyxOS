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
      # Krohnkite is a tiling window manager for plasma
      scripts.krohnkite = {
        enable = true;
        settings = {
          gaps = {
            top = 2;
            right = 2;
            bottom = 0;
            left = 2;
            tiles = 5;
          };
          layouts.enabled = [
            "tile"
            {
              name = "monocle";
              options = { maximize = false; minimizeRest = false; };

            }
            "spiral"
          ];
          maximizeSoleTile = false;
          keepFloatAbove = true;
          keepTilingOnDrag = true;
          preventMinimize = false;
          preventProtrusion = true;
          noTileBorders = false;
          floatUtility = true;
          ignoreRoles = [
            "quake"
          ];
          ignoreClasses = [
            "krunner"
            "yakuake"
            "spectacle"
            "kded5"
            "xwaylandvideobridge"
            "plasmashell"
            "ksplashqml"
            "org.kde.plasmashell"
            "org.kde.polkit-kde-authentication-agent-1"
            "org.kde.kruler"
            "kruler"
          ];
        };
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
                "applications:super-productivity.desktop"
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
                iconSpacing = "small";
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
              calendar.showWeekNumbers = true;
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
                showAll = false;
                shown = [
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
                show_requestLogoutScreen = false;
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
                show_requestLogoutScreen = false;
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
                show_requestLogoutScreen = false;
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
                show_requestLogoutScreen = false;
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
              presetAutoLoading = {
                normal = "Default Nixos";
              };
            };
          }
        ];
      }
    ];
    powerdevil.AC.dimDisplay.enable = false;
    session.sessionRestore.restoreOpenApplicationsOnLogin = "startWithEmptySession";
    shortcuts = {
      "KDE Keyboard Layout Switcher"."Switch keyboard layout to German (Austria)" = [ ];
      "KDE Keyboard Layout Switcher"."Switch to Last-Used Keyboard Layout" = [ ];
      "KDE Keyboard Layout Switcher"."Switch to Next Keyboard Layout" = [ ];
      "kaccess"."Toggle Screen Reader On and Off" = "Meta+Alt+S";
      "kcm_touchpad"."Disable Touchpad" = "Touchpad Off";
      "kcm_touchpad"."Enable Touchpad" = "Touchpad On";
      "kcm_touchpad"."Toggle Touchpad" = "Touchpad Toggle";
      "kmix"."decrease_microphone_volume" = "Microphone Volume Down";
      "kmix"."decrease_volume" = "Volume Down";
      "kmix"."decrease_volume_small" = "Shift+Volume Down";
      "kmix"."increase_microphone_volume" = "Microphone Volume Up";
      "kmix"."increase_volume" = "Volume Up";
      "kmix"."increase_volume_small" = "Shift+Volume Up";
      "kmix"."mic_mute" = [ "Microphone Mute" "Meta+Volume Mute" ];
      "kmix"."mute" = "Volume Mute";
      "ksmserver"."Halt Without Confirmation" = [ ];
      "ksmserver"."Lock Session" = [ "Meta+L" "Screensaver" ];
      "ksmserver"."Log Out Without Confirmation" = [ ];
      "ksmserver"."Log Out" = "Ctrl+Alt+Del";
      "ksmserver"."Reboot Without Confirmation" = [ ];
      "ksmserver"."Reboot" = [ ];
      "ksmserver"."Shut Down" = [ ];
      "kwin"."Activate Window Demanding Attention" = "Meta+Ctrl+A";
      "kwin"."Cycle Overview Opposite" = [ ];
      "kwin"."Cycle Overview" = [ ];
      "kwin"."Decrease Opacity" = [ ];
      "kwin"."Edit Tiles" = "none,Meta+T,Toggle Tiles Editor";
      "kwin"."Expose" = "Ctrl+F9";
      "kwin"."ExposeAll" = "Ctrl+F10";
      "kwin"."ExposeClass" = "Ctrl+F7";
      "kwin"."ExposeClassCurrentDesktop" = [ ];
      "kwin"."Grid View" = "Meta+G";
      "kwin"."Increase Opacity" = [ ];
      "kwin"."Kill Window" = "Meta+Ctrl+Esc";
      "kwin"."KrohnkiteBTreeLayout" = [ ];
      "kwin"."KrohnkiteColumnsLayout" = [ ];
      "kwin"."KrohnkiteDecrease" = "Meta+U";
      "kwin"."KrohnkiteFloatAll" = "Meta+Shift+F";
      "kwin"."KrohnkiteFloatingLayout" = [ ];
      "kwin"."KrohnkiteFocusDown" = [ ];
      "kwin"."KrohnkiteFocusLeft" = [ ];
      "kwin"."KrohnkiteFocusNext" = "Meta+.";
      "kwin"."KrohnkiteFocusPrev" = "Meta+\\,";
      "kwin"."KrohnkiteFocusRight" = [ ];
      "kwin"."KrohnkiteFocusUp" = [ ];
      "kwin"."KrohnkiteGrowHeight" = "Meta+Shift+I";
      "kwin"."KrohnkiteIncrease" = "Meta+I";
      "kwin"."KrohnkiteMonocleLayout" = "Meta+M";
      "kwin"."KrohnkiteNextLayout" = "Meta+T";
      "kwin"."KrohnkitePreviousLayout" = [ ];
      "kwin"."KrohnkiteQuarterLayout" = [ ];
      "kwin"."KrohnkiteRotate" = "Meta+R";
      "kwin"."KrohnkiteRotatePart" = [ ];
      "kwin"."KrohnkiteSetMaster" = "Meta+Return";
      "kwin"."KrohnkiteShiftDown" = "Meta+Down";
      "kwin"."KrohnkiteShiftLeft" = "Meta+Left";
      "kwin"."KrohnkiteShiftRight" = "Meta+Right";
      "kwin"."KrohnkiteShiftUp" = "Meta+Up";
      "kwin"."KrohnkiteShrinkHeight" = "Meta+Shift+U";
      "kwin"."KrohnkiteShrinkWidth" = "Meta+Ctrl+U";
      "kwin"."KrohnkiteSpiralLayout" = [ ];
      "kwin"."KrohnkiteSpreadLayout" = [ ];
      "kwin"."KrohnkiteStackedLayout" = [ ];
      "kwin"."KrohnkiteStairLayout" = [ ];
      "kwin"."KrohnkiteTileLayout" = [ ];
      "kwin"."KrohnkiteToggleFloat" = "Meta+F";
      "kwin"."KrohnkiteTreeColumnLayout" = [ ];
      "kwin"."KrohnkitegrowWidth" = "Meta+Ctrl+I";
      "kwin"."Move Tablet to Next Output" = [ ];
      "kwin"."MoveMouseToCenter" = "Meta+F6";
      "kwin"."MoveMouseToFocus" = "Meta+F5";
      "kwin"."MoveZoomDown" = [ ];
      "kwin"."MoveZoomLeft" = [ ];
      "kwin"."MoveZoomRight" = [ ];
      "kwin"."MoveZoomUp" = [ ];
      "kwin"."Overview" = "Meta+W";
      "kwin"."Setup Window Shortcut" = [ ];
      "kwin"."Show Desktop" = "Meta+D";
      "kwin"."Switch One Desktop Down" = "Meta+Ctrl+Down";
      "kwin"."Switch One Desktop Up" = "Meta+Ctrl+Up";
      "kwin"."Switch One Desktop to the Left" = "Meta+Ctrl+Left";
      "kwin"."Switch One Desktop to the Right" = "Meta+Ctrl+Right";
      "kwin"."Switch Window Down" = "Meta+Alt+Down";
      "kwin"."Switch Window Left" = "Meta+Alt+Left";
      "kwin"."Switch Window Right" = "Meta+Alt+Right";
      "kwin"."Switch Window Up" = "Meta+Alt+Up";
      "kwin"."Switch to Desktop 1" = "Ctrl+F1";
      "kwin"."Switch to Desktop 10" = [ ];
      "kwin"."Switch to Desktop 11" = [ ];
      "kwin"."Switch to Desktop 12" = [ ];
      "kwin"."Switch to Desktop 13" = [ ];
      "kwin"."Switch to Desktop 14" = [ ];
      "kwin"."Switch to Desktop 15" = [ ];
      "kwin"."Switch to Desktop 16" = [ ];
      "kwin"."Switch to Desktop 17" = [ ];
      "kwin"."Switch to Desktop 18" = [ ];
      "kwin"."Switch to Desktop 19" = [ ];
      "kwin"."Switch to Desktop 2" = "Ctrl+F2";
      "kwin"."Switch to Desktop 20" = [ ];
      "kwin"."Switch to Desktop 3" = "Ctrl+F3";
      "kwin"."Switch to Desktop 4" = "Ctrl+F4";
      "kwin"."Switch to Desktop 5" = [ ];
      "kwin"."Switch to Desktop 6" = [ ];
      "kwin"."Switch to Desktop 7" = [ ];
      "kwin"."Switch to Desktop 8" = [ ];
      "kwin"."Switch to Desktop 9" = [ ];
      "kwin"."Switch to Next Desktop" = [ ];
      "kwin"."Switch to Next Screen" = [ ];
      "kwin"."Switch to Previous Desktop" = [ ];
      "kwin"."Switch to Previous Screen" = [ ];
      "kwin"."Switch to Screen 0" = [ ];
      "kwin"."Switch to Screen 1" = [ ];
      "kwin"."Switch to Screen 2" = [ ];
      "kwin"."Switch to Screen 3" = [ ];
      "kwin"."Switch to Screen 4" = [ ];
      "kwin"."Switch to Screen 5" = [ ];
      "kwin"."Switch to Screen 6" = [ ];
      "kwin"."Switch to Screen 7" = [ ];
      "kwin"."Switch to Screen Above" = [ ];
      "kwin"."Switch to Screen Below" = [ ];
      "kwin"."Switch to Screen to the Left" = [ ];
      "kwin"."Switch to Screen to the Right" = [ ];
      "kwin"."Toggle Night Color" = [ ];
      "kwin"."Toggle Window Raise/Lower" = [ ];
      "kwin"."Walk Through Windows (Reverse)" = "Alt+Shift+Tab";
      "kwin"."Walk Through Windows Alternative (Reverse)" = [ ];
      "kwin"."Walk Through Windows Alternative" = [ ];
      "kwin"."Walk Through Windows of Current Application (Reverse)" = [ ];
      "kwin"."Walk Through Windows of Current Application Alternative (Reverse)" = [ ];
      "kwin"."Walk Through Windows of Current Application Alternative" = [ ];
      "kwin"."Walk Through Windows of Current Application" = [ ];
      "kwin"."Walk Through Windows" = "Alt+Tab";
      "kwin"."Window Above Other Windows" = [ ];
      "kwin"."Window Below Other Windows" = [ ];
      "kwin"."Window Close" = "Alt+F4";
      "kwin"."Window Fullscreen" = [ ];
      "kwin"."Window Grow Horizontal" = [ ];
      "kwin"."Window Grow Vertical" = [ ];
      "kwin"."Window Lower" = [ ];
      "kwin"."Window Maximize Horizontal" = [ ];
      "kwin"."Window Maximize Vertical" = [ ];
      "kwin"."Window Maximize" = "Meta+PgUp";
      "kwin"."Window Minimize" = "Meta+PgDown";
      "kwin"."Window Move Center" = [ ];
      "kwin"."Window Move" = [ ];
      "kwin"."Window No Border" = [ ];
      "kwin"."Window On All Desktops" = [ ];
      "kwin"."Window One Desktop Down" = "Meta+Ctrl+Shift+Down";
      "kwin"."Window One Desktop Up" = "Meta+Ctrl+Shift+Up";
      "kwin"."Window One Desktop to the Left" = "Meta+Ctrl+Shift+Left";
      "kwin"."Window One Desktop to the Right" = "Meta+Ctrl+Shift+Right";
      "kwin"."Window One Screen Down" = [ ];
      "kwin"."Window One Screen Up" = [ ];
      "kwin"."Window One Screen to the Left" = [ ];
      "kwin"."Window One Screen to the Right" = [ ];
      "kwin"."Window Operations Menu" = "Alt+F3";
      "kwin"."Window Pack Down" = [ ];
      "kwin"."Window Pack Left" = [ ];
      "kwin"."Window Pack Right" = [ ];
      "kwin"."Window Pack Up" = [ ];
      "kwin"."Window Quick Tile Bottom Left" = [ ];
      "kwin"."Window Quick Tile Bottom Right" = [ ];
      "kwin"."Window Quick Tile Bottom" = [ ];
      "kwin"."Window Quick Tile Left" = [ ];
      "kwin"."Window Quick Tile Right" = [ ];
      "kwin"."Window Quick Tile Top Left" = [ ];
      "kwin"."Window Quick Tile Top Right" = [ ];
      "kwin"."Window Quick Tile Top" = [ ];
      "kwin"."Window Raise" = [ ];
      "kwin"."Window Resize" = [ ];
      "kwin"."Window Shade" = [ ];
      "kwin"."Window Shrink Horizontal" = [ ];
      "kwin"."Window Shrink Vertical" = [ ];
      "kwin"."Window to Desktop 1" = [ ];
      "kwin"."Window to Desktop 10" = [ ];
      "kwin"."Window to Desktop 11" = [ ];
      "kwin"."Window to Desktop 12" = [ ];
      "kwin"."Window to Desktop 13" = [ ];
      "kwin"."Window to Desktop 14" = [ ];
      "kwin"."Window to Desktop 15" = [ ];
      "kwin"."Window to Desktop 16" = [ ];
      "kwin"."Window to Desktop 17" = [ ];
      "kwin"."Window to Desktop 18" = [ ];
      "kwin"."Window to Desktop 19" = [ ];
      "kwin"."Window to Desktop 2" = [ ];
      "kwin"."Window to Desktop 20" = [ ];
      "kwin"."Window to Desktop 3" = [ ];
      "kwin"."Window to Desktop 4" = [ ];
      "kwin"."Window to Desktop 5" = [ ];
      "kwin"."Window to Desktop 6" = [ ];
      "kwin"."Window to Desktop 7" = [ ];
      "kwin"."Window to Desktop 8" = [ ];
      "kwin"."Window to Desktop 9" = [ ];
      "kwin"."Window to Next Desktop" = [ ];
      "kwin"."Window to Next Screen" = "Meta+Shift+Right";
      "kwin"."Window to Previous Desktop" = [ ];
      "kwin"."Window to Previous Screen" = "Meta+Shift+Left";
      "kwin"."Window to Screen 0" = [ ];
      "kwin"."Window to Screen 1" = [ ];
      "kwin"."Window to Screen 2" = [ ];
      "kwin"."Window to Screen 3" = [ ];
      "kwin"."Window to Screen 4" = [ ];
      "kwin"."Window to Screen 5" = [ ];
      "kwin"."Window to Screen 6" = [ ];
      "kwin"."Window to Screen 7" = [ ];
      "kwin"."toggleTilesEditor" = [ ];
      "kwin"."view_actual_size" = "Meta+0";
      "kwin"."view_zoom_in" = "Meta++";
      "kwin"."view_zoom_out" = "Meta+-";
      "mediacontrol"."mediavolumedown" = [ ];
      "mediacontrol"."mediavolumeup" = [ ];
      "mediacontrol"."nextmedia" = "Media Next";
      "mediacontrol"."pausemedia" = "Media Pause";
      "mediacontrol"."playmedia" = [ ];
      "mediacontrol"."playpausemedia" = "Media Play";
      "mediacontrol"."previousmedia" = "Media Previous";
      "mediacontrol"."stopmedia" = "Media Stop";
      "org.kde.spectacle.desktop"."ActiveWindowScreenShot" = "Meta+Print";
      "org.kde.spectacle.desktop"."CurrentMonitorScreenShot" = "Print";
      "org.kde.spectacle.desktop"."FullScreenScreenShot" = "Shift+Print";
      "org.kde.spectacle.desktop"."OpenWithoutScreenshot" = "Meta+Alt+S";
      "org.kde.spectacle.desktop"."RecordRegion" = "Meta+Shift+R";
      "org.kde.spectacle.desktop"."RecordScreen" = "Meta+Alt+R";
      "org.kde.spectacle.desktop"."RecordWindow" = "Meta+Ctrl+R";
      "org.kde.spectacle.desktop"."RectangularRegionScreenShot" = "Meta+Shift+S";
      "org.kde.spectacle.desktop"."WindowUnderCursorScreenShot" = "Meta+Ctrl+Print";
      "org.kde.spectacle.desktop"."_launch" = "Meta+S";
      "org_kde_powerdevil"."Decrease Keyboard Brightness" = "Keyboard Brightness Down";
      "org_kde_powerdevil"."Decrease Screen Brightness Small" = "Shift+Monitor Brightness Down";
      "org_kde_powerdevil"."Decrease Screen Brightness" = "Monitor Brightness Down";
      "org_kde_powerdevil"."Hibernate" = "Hibernate";
      "org_kde_powerdevil"."Increase Keyboard Brightness" = "Keyboard Brightness Up";
      "org_kde_powerdevil"."Increase Screen Brightness Small" = "Shift+Monitor Brightness Up";
      "org_kde_powerdevil"."Increase Screen Brightness" = "Monitor Brightness Up";
      "org_kde_powerdevil"."PowerDown" = "Power Down";
      "org_kde_powerdevil"."PowerOff" = "Power Off";
      "org_kde_powerdevil"."Sleep" = "Sleep";
      "org_kde_powerdevil"."Toggle Keyboard Backlight" = "Keyboard Light On/Off";
      "org_kde_powerdevil"."Turn Off Screen" = [ ];
      "org_kde_powerdevil"."powerProfile" = "Meta+B";
      "plasmashell"."activate application launcher" = "Meta";
      "plasmashell"."activate task manager entry 1" = "Meta+1";
      "plasmashell"."activate task manager entry 10" = "Meta+0";
      "plasmashell"."activate task manager entry 2" = "Meta+2";
      "plasmashell"."activate task manager entry 3" = "Meta+3";
      "plasmashell"."activate task manager entry 4" = "Meta+4";
      "plasmashell"."activate task manager entry 5" = "Meta+5";
      "plasmashell"."activate task manager entry 6" = "Meta+6";
      "plasmashell"."activate task manager entry 7" = "Meta+7";
      "plasmashell"."activate task manager entry 8" = "Meta+8";
      "plasmashell"."activate task manager entry 9" = "Meta+9";
      "plasmashell"."clear-history" = [ ];
      "plasmashell"."clipboard_action" = "Meta+Ctrl+X";
      "plasmashell"."cycle-panels" = "Meta+Alt+P";
      "plasmashell"."cycleNextAction" = [ ];
      "plasmashell"."cyclePrevAction" = [ ];
      "plasmashell"."manage activities" = "Meta+Q";
      "plasmashell"."next activity" = "Meta+A";
      "plasmashell"."previous activity" = "Meta+Shift+A";
      "plasmashell"."repeat_action" = "noned";
      "plasmashell"."show dashboard" = "Ctrl+F12";
      "plasmashell"."show-barcode" = [ ];
      "plasmashell"."show-on-mouse-pos" = "Meta+V";
      "plasmashell"."stop current activity" = "Meta+S";
      "plasmashell"."switch to next activity" = [ ];
      "plasmashell"."switch to previous activity" = [ ];
      "plasmashell"."toggle do not disturb" = [ ];
      "services/kitty.desktop"."_launch" = "Meta+X";
      "services/org.kde.plasma.emojier.desktop"."_launch" = "Meta+Ctrl+Alt+Shift+Space";
      "services/org.kde.spectacle.desktop"."CurrentMonitorScreenShot" = "Print";
      "services/org.kde.spectacle.desktop"."OpenWithoutScreenshot" = [ ];
      "services/org.kde.spectacle.desktop"."RecordRegion" = "Meta+Shift+R";
      "services/org.kde.spectacle.desktop"."RectangularRegionScreenShot" = "Meta+Shift+S";
      "services/org.kde.spectacle.desktop"."_launch" = [ ];
    };
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
      iconTheme = "Papirus-Dark";
      wallpaper = "/home/elias/NyxOS/images/HeightLinesMocha.png";
      colorScheme = "CatppuccinMochaFlamingo";
      soundTheme = "ocean";
      splashScreen = {
        theme = "None";
      };
    };
  };
}
