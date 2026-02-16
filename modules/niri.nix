{ inputs, ... }: {
  flake-file.inputs = {
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.quickshell.follows = "quickshell";
    };
    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    danksearch = {
      url = "github:AvengeMedia/danksearch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # System Module niri: Niri + DankMaterialShell
  flake.modules.nixos.niri = { pkgs, ... }: {
    imports = [
      inputs.niri.nixosModules.niri
      inputs.dms.nixosModules.dank-material-shell
    ];

    environment.systemPackages = with pkgs; [
      xwayland-satellite # xwayland support

      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
      brightnessctl
      wl-mirror

      # file previews
      libgsf
    ];

    services.accounts-daemon.enable = true;
    services.upower.enable = true;

    programs.niri.enable = true;
    nixpkgs.overlays = [ inputs.niri.overlays.niri ];
    programs.niri.package = pkgs.niri-unstable;

    environment.variables = {
      NIXOS_OZONE_WL = "1";
      XDG_CURRENT_DESKTOP = "niri:GNOME";
    };

    # DMS has its own polkit agent, so we disable niri's to avoid conflicts
    systemd.user.services.niri-flake-polkit.enable = false;

    services.displayManager.dms-greeter = {
      enable = true;
      compositor.name = "niri";
    };

    programs.thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-archive-plugin
        thunar-volman
        thunar-media-tags-plugin
      ];
    };

    programs.xfconf.enable = true; # To persist thunar config
    services.gvfs.enable = true; # Mount, trash, and other functionalities
    services.samba.enable = true; # Remote drives
    services.tumbler.enable = true; # Thumbnail support for images

    home-manager.sharedModules = [
      inputs.self.modules.homeManager.niri
    ];
  };

  # Home Module niri: Niri + DankMaterialShell
  flake.modules.homeManager.niri = { pkgs, lib, config, showBattery, ... }: {
    imports = [
      inputs.dms.homeModules.dank-material-shell
      inputs.dms.homeModules.niri
      inputs.dms-plugin-registry.modules.default
      inputs.danksearch.homeModules.dsearch
    ];

    programs.dsearch = {
      enable = true;

      # Custom configuration (TOML format)
      config = {
        # Server configuration
        listen_addr = ":43654";

        # Index settings
        index_path = "${config.home.homeDirectory}/.cache/danksearch/index";
        max_file_bytes = 8388608; # 8MB
        worker_count = 4;
        index_all_files = true;

        # Auto-reindex settings
        auto_reindex = true;
        reindex_interval_hours = 24;

        # Text file extensions
        text_extensions = [
          ".txt"
          ".md"
          ".go"
          ".py"
          ".js"
          ".ts"
          ".jsx"
          ".tsx"
          ".java"
          ".json"
          ".yaml"
          ".yml"
          ".toml"
          ".html"
          ".css"
          ".rs"
          ".cs"
          ".csproj"
          ".sln"
          ".slnx"
          ".blazor"
        ];

        # Index paths configuration
        index_paths = [
          {
            path = "${config.home.homeDirectory}";
            max_depth = 8;
            exclude_hidden = true;
            exclude_dirs = [ "node_modules" ".git" "target" "dist" "bin" "obj" "build" ];
          }
        ];
      };
    };

    programs.niri =
      {
        settings = {
          input = {
            keyboard.xkb.layout = "at";
          };
          # output is managed by DMS
          layout = {
            # Here i could make fancy shit
            gaps = 5;
            preset-column-widths = [
              { proportion = 1.0 / 3.0; }
              { proportion = 1.0 / 2.0; }
              { proportion = 2.0 / 3.0; }
              { proportion = 0.9; }
              { proportion = 1.0; }
            ];

            preset-window-heights = [
              { proportion = 1.0 / 3.0; }
              { proportion = 1.0 / 2.0; }
              { proportion = 2.0 / 3.0; }
              { proportion = 0.9; }
              { proportion = 1.0; }
            ];
          };
          hotkey-overlay = {
            skip-at-startup = true; # Don't show the hotkey overlay on startup
            hide-not-bound = true; # Don't show actions that don't have hotkeys bound to them
          };
          window-rules = [
            {
              matches = [{
                is-window-cast-target = true;
              }];
              focus-ring.active.color = "#ff0000";
              focus-ring.inactive.color = "#900030";
              border.inactive.color = "#900030";
              shadow.color = "#900030";
              tab-indicator.active.color = "#ff0000";
              tab-indicator.inactive.color = "#900030";
            }
          ];
          # window-rule could be useful to exclude certain windows from being tiled.
          gestures = {
            hot-corners.enable = false;
            dnd-edge-view-scroll = {
              delay-ms = 100;
              max-speed = 1500;
              trigger-width = 30;
            };
            dnd-edge-workspace-switch = {
              delay-ms = 100;
              max-speed = 1500;
              trigger-height = 50;
            };
          };
          xwayland-satellite = {
            enable = true;
            path = lib.getExe pkgs.xwayland-satellite;
          };
          switch-events = {
            lid-close.action.spawn = [ "dms" "ipc" "call" "lock" "lock" ];
          };
          binds = {
            # shows a list of important hotkeys.
            "Mod+I" = {
              action.show-hotkey-overlay = [ ];
              hotkey-overlay.title = "Show Hotkeys";
            };

            "Mod+T" = {
              action.spawn = "kitty";
              hotkey-overlay.title = "Open Terminal";
            };

            "Super+L" = {
              action.spawn = [ "dms" "ipc" "call" "lock" "lock" ];
              hotkey-overlay.title = "Lock Screen";
            };

            "Mod+Space" = {
              action.spawn = [ "dms" "ipc" "spotlight" "toggle" ];
              hotkey-overlay.title = "Toggle Application Launcher";
            };

            "Mod+B" = {
              action.spawn = "firefox";
              hotkey-overlay.title = "Open Firefox";
            };

            "Mod+V" = {
              action.spawn = [ "dms" "ipc" "clipboard" "toggle" ];
              hotkey-overlay.title = "Open Clipboard";
            };

            "Mod+P" = {
              action.set-dynamic-cast-window = [ ];
              hotkey-overlay.title = "Set Focused Window as Screencast Target";
            };

            "Mod+Ctrl+P" = {
              action.spawn-sh = "wl-mirror $(niri msg --json focused-output | jq -r .name)";
              repeat = false;
              hotkey-overlay.title = "Start Screen Mirror";
            };

            # Powers off the monitors. To turn them back on, do any input like
            # moving the mouse or pressing any other key.
            "Mod+Shift+P" = {
              action.power-off-monitors = [ ];
              hotkey-overlay.title = "Power Off Monitors";
            };

            # Open/close the Overview: a zoomed-out view of workspaces and windows.
            # or do a four-finger swipe up on a touchpad.
            "Mod+Tab" = {
              action.toggle-overview = [ ];
              repeat = false;
              hotkey-overlay.title = "Toggle Overview";
            };

            "Alt+F4" = {
              action.close-window = [ ];
              repeat = false;
              hotkey-overlay.title = "Close Window";
            };

            # Focus navigation with arrow keys or WASD
            # Arrow key navigation
            "Mod+Left" = {
              action.focus-column-or-monitor-left = [ ];
              hotkey-overlay.title = "Focus Left Column or Monitor (Also Mod+A, +Shift => Monitor, +Ctrl => Move, +Shift+Ctrl => Move to Monitor)";
            };
            "Mod+Down" = {
              action.focus-window-or-monitor-down = [ ];
              hotkey-overlay.title = "Focus Window or Monitor Down (Also Mod+S, +Shift => Monitor, +Ctrl => Move, +Shift+Ctrl => Move to Monitor)";
            };
            "Mod+Up" = {
              action.focus-window-or-monitor-up = [ ];
              hotkey-overlay.title = "Focus Window or Monitor Up (Also Mod+W, +Shift => Monitor, +Ctrl => Move, +Shift+Ctrl => Move to Monitor)";
            };
            "Mod+Right" = {
              action.focus-column-or-monitor-right = [ ];
              hotkey-overlay.title = "Focus Right Column or Monitor (Also Mod+D, +Shift => Monitor, +Ctrl => Move, +Shift+Ctrl => Move to Monitor)";
            };

            "Mod+A" = { action.focus-column-or-monitor-left = [ ]; };
            "Mod+S" = { action.focus-window-or-monitor-down = [ ]; hotkey-overlay.hidden = true; };
            "Mod+W" = { action.focus-window-or-monitor-up = [ ]; hotkey-overlay.hidden = true; };
            "Mod+D" = { action.focus-column-or-monitor-right = [ ]; hotkey-overlay.hidden = true; };

            # Ctrl arrow movement
            "Mod+Ctrl+Left" = { action.move-column-left-or-to-monitor-left = [ ]; hotkey-overlay.hidden = true; };
            "Mod+Ctrl+Down" = { action.move-window-down = [ ]; hotkey-overlay.hidden = true; };
            "Mod+Ctrl+Up" = { action.move-window-up = [ ]; hotkey-overlay.hidden = true; };
            "Mod+Ctrl+Right" = { action.move-column-right-or-to-monitor-right = [ ]; hotkey-overlay.hidden = true; };
            "Mod+Ctrl+A" = { action.move-column-left-or-to-monitor-left = [ ]; hotkey-overlay.hidden = true; };
            "Mod+Ctrl+S" = { action.move-window-down = [ ]; hotkey-overlay.hidden = true; };
            "Mod+Ctrl+W" = { action.move-window-up = [ ]; hotkey-overlay.hidden = true; };
            "Mod+Ctrl+D" = { action.move-column-right-or-to-monitor-right = [ ]; hotkey-overlay.hidden = true; };

            # Home and End keys for column edge navigation
            "Mod+Home" = {
              action.focus-column-first = [ ];
              hotkey-overlay.title = "Focus First Column (+Ctrl => Move)";
            };
            "Mod+End" = {
              action.focus-column-last = [ ];
              hotkey-overlay.title = "Focus Last Column (+Ctrl => Move)";
            };
            "Mod+Ctrl+Home" = { action.move-column-to-first = [ ]; hotkey-overlay.hidden = true; };
            "Mod+Ctrl+End" = { action.move-column-to-last = [ ]; hotkey-overlay.hidden = true; };

            # Monitor focus with Shift modifiers
            "Mod+Shift+Left" = { action.focus-monitor-left = [ ]; hotkey-overlay.hidden = true; };
            "Mod+Shift+Down" = { action.focus-monitor-down = [ ]; hotkey-overlay.hidden = true; };
            "Mod+Shift+Up" = { action.focus-monitor-up = [ ]; hotkey-overlay.hidden = true; };
            "Mod+Shift+Right" = { action.focus-monitor-right = [ ]; hotkey-overlay.hidden = true; };
            "Mod+Shift+A" = { action.focus-monitor-left = [ ]; hotkey-overlay.hidden = true; };
            "Mod+Shift+S" = { action.focus-monitor-down = [ ]; hotkey-overlay.hidden = true; };
            "Mod+Shift+W" = { action.focus-monitor-up = [ ]; hotkey-overlay.hidden = true; };
            "Mod+Shift+D" = { action.focus-monitor-right = [ ]; hotkey-overlay.hidden = true; };

            # Move columns to different monitors
            "Mod+Shift+Ctrl+Left" = { action.move-column-to-monitor-left = [ ]; hotkey-overlay.hidden = true; };
            "Mod+Shift+Ctrl+Down" = { action.move-column-to-monitor-down = [ ]; hotkey-overlay.hidden = true; };
            "Mod+Shift+Ctrl+Up" = { action.move-column-to-monitor-up = [ ]; hotkey-overlay.hidden = true; };
            "Mod+Shift+Ctrl+Right" = { action.move-column-to-monitor-right = [ ]; hotkey-overlay.hidden = true; };
            "Mod+Shift+Ctrl+A" = { action.move-column-to-monitor-left = [ ]; hotkey-overlay.hidden = true; };
            "Mod+Shift+Ctrl+S" = { action.move-column-to-monitor-down = [ ]; hotkey-overlay.hidden = true; };
            "Mod+Shift+Ctrl+W" = { action.move-column-to-monitor-up = [ ]; hotkey-overlay.hidden = true; };
            "Mod+Shift+Ctrl+D" = { action.move-column-to-monitor-right = [ ]; hotkey-overlay.hidden = true; };

            "Mod+Page_Down" = {
              action.focus-workspace-down = [ ];
              hotkey-overlay.title = "Focus Next Workspace (Also Mod+E, +Shift => Move Workspace, +Ctrl => Move focused column)";
            };
            "Mod+Page_Up" = {
              action.focus-workspace-up = [ ];
              hotkey-overlay.title = "Focus Previous Workspace (Also Mod+Q, +Shift => Move Workspace, +Ctrl => Move focused column)";
            };
            "Mod+E" = { action.focus-workspace-down = [ ]; hotkey-overlay.hidden = true; };
            "Mod+Q" = { action.focus-workspace-up = [ ]; hotkey-overlay.hidden = true; };

            # Move columns to different workspaces
            "Mod+Ctrl+Page_Down" = { action.move-column-to-workspace-down = [ ]; hotkey-overlay.hidden = true; };
            "Mod+Ctrl+Page_Up" = { action.move-column-to-workspace-up = [ ]; hotkey-overlay.hidden = true; };
            "Mod+Ctrl+E" = { action.move-column-to-workspace-down = [ ]; hotkey-overlay.hidden = true; };
            "Mod+Ctrl+Q" = { action.move-column-to-workspace-up = [ ]; hotkey-overlay.hidden = true; };

            # Move entire workspaces to adjacent positions
            "Mod+Shift+Page_Down" = { action.move-workspace-down = [ ]; hotkey-overlay.hidden = true; };
            "Mod+Shift+Page_Up" = { action.move-workspace-up = [ ]; hotkey-overlay.hidden = true; };
            "Mod+Shift+E" = { action.move-workspace-down = [ ]; hotkey-overlay.hidden = true; };
            "Mod+Shift+Q" = { action.move-workspace-up = [ ]; hotkey-overlay.hidden = true; };

            # Mouse wheel scroll bindings
            # You can bind mouse wheel scroll ticks using the following syntax.
            # These binds will change direction based on the natural-scroll setting.
            # To avoid scrolling through workspaces really fast, you can use
            # the cooldown-ms property. The bind will be rate-limited to this value.
            # You can set a cooldown on any bind, but it's most useful for the wheel.
            "Mod+WheelScrollDown" = {
              action.focus-column-or-monitor-right = [ ];
              cooldown-ms = 100;
              hotkey-overlay.title = "Focus right Column or Monitor (+Shift => Workspace, +Ctrl => Move, +Shift+Ctrl => Move to Workspace)";
            };
            "Mod+WheelScrollUp" = {
              action.focus-column-or-monitor-left = [ ];
              cooldown-ms = 100;
              hotkey-overlay.title = "Focus left Column or Monitor (+Shift => Workspace, +Ctrl => Move, +Shift+Ctrl => Move to Workspace)";
            };
            "Mod+Ctrl+WheelScrollDown" = {
              action.move-column-right-or-to-monitor-right = [ ];
              cooldown-ms = 100;
              hotkey-overlay.hidden = true;
            };
            "Mod+Ctrl+WheelScrollUp" = {
              action.move-column-left-or-to-monitor-left = [ ];
              cooldown-ms = 100;
              hotkey-overlay.hidden = true;
            };
            "Mod+Shift+WheelScrollDown" = {
              action.focus-workspace-down = [ ];
              cooldown-ms = 100;
              hotkey-overlay.hidden = true;
            };
            "Mod+Shift+WheelScrollUp" = {
              action.focus-workspace-up = [ ];
              cooldown-ms = 100;
              hotkey-overlay.hidden = true;
            };
            "Mod+Ctrl+Shift+WheelScrollDown" = {
              action.move-column-to-workspace-down = [ ];
              cooldown-ms = 100;
              hotkey-overlay.hidden = true;
            };
            "Mod+Ctrl+Shift+WheelScrollUp" = {
              action.move-column-to-workspace-up = [ ];
              cooldown-ms = 100;
              hotkey-overlay.hidden = true;
            };

            "Mod+WheelScrollRight" = {
              action.focus-workspace-down = [ ];
              hotkey-overlay.title = "Focus Next Workspace (also MouseForward, +Ctrl => Move focused column)";
            };
            "Mod+WheelScrollLeft" = {
              action.focus-workspace-up = [ ];
              hotkey-overlay.title = "Focus Previous Workspace (also MouseBack, +Ctrl => Move focused column)";
            };
            "Mod+Ctrl+WheelScrollRight" = { action.move-column-to-workspace-down = [ ]; hotkey-overlay.hidden = true; };
            "Mod+Ctrl+WheelScrollLeft" = { action.move-column-to-workspace-up = [ ]; hotkey-overlay.hidden = true; };
            "Mod+MouseForward" = { action.focus-workspace-down = [ ]; hotkey-overlay.hidden = true; };
            "Mod+MouseBack" = { action.focus-workspace-up = [ ]; hotkey-overlay.hidden = true; };
            "Mod+Ctrl+MouseForward" = { action.move-column-to-workspace-down = [ ]; hotkey-overlay.hidden = true; };
            "Mod+Ctrl+MouseBack" = { action.move-column-to-workspace-up = [ ]; hotkey-overlay.hidden = true; };

            # Direct workspace selection by number
            # For example, with 2 workspaces + 1 empty, indices 3, 4, 5 and so on
            # will all refer to the 3rd workspace.
            "Mod+1" = {
              action.focus-workspace = 1;
              hotkey-overlay.title = "Focus Workspace 1-9 (+Ctrl => Move focused column)";
            };
            "Mod+2" = { action.focus-workspace = 2; hotkey-overlay.hidden = true; };
            "Mod+3" = { action.focus-workspace = 3; hotkey-overlay.hidden = true; };
            "Mod+4" = { action.focus-workspace = 4; hotkey-overlay.hidden = true; };
            "Mod+5" = { action.focus-workspace = 5; hotkey-overlay.hidden = true; };
            "Mod+6" = { action.focus-workspace = 6; hotkey-overlay.hidden = true; };
            "Mod+7" = { action.focus-workspace = 7; hotkey-overlay.hidden = true; };
            "Mod+8" = { action.focus-workspace = 8; hotkey-overlay.hidden = true; };
            "Mod+9" = { action.focus-workspace = 9; hotkey-overlay.hidden = true; };

            # Move to workspace number
            "Mod+Ctrl+1" = { action.move-column-to-workspace = 1; hotkey-overlay.hidden = true; };
            "Mod+Ctrl+2" = { action.move-column-to-workspace = 2; hotkey-overlay.hidden = true; };
            "Mod+Ctrl+3" = { action.move-column-to-workspace = 3; hotkey-overlay.hidden = true; };
            "Mod+Ctrl+4" = { action.move-column-to-workspace = 4; hotkey-overlay.hidden = true; };
            "Mod+Ctrl+5" = { action.move-column-to-workspace = 5; hotkey-overlay.hidden = true; };
            "Mod+Ctrl+6" = { action.move-column-to-workspace = 6; hotkey-overlay.hidden = true; };
            "Mod+Ctrl+7" = { action.move-column-to-workspace = 7; hotkey-overlay.hidden = true; };
            "Mod+Ctrl+8" = { action.move-column-to-workspace = 8; hotkey-overlay.hidden = true; };
            "Mod+Ctrl+9" = { action.move-column-to-workspace = 9; hotkey-overlay.hidden = true; };

            # The following binds move the focused window in and out of a column.
            # If the window is alone, they will consume it into the nearby column to the side.
            # If the window is already in a column, they will expel it out.
            "Mod+Comma" = {
              action.consume-or-expel-window-left = [ ];
              hotkey-overlay.title = "Consume or Expel Window Left (This means stacking it to the column to the left / breaking it out of a stack to the left)";
            };
            "Mod+Period" = {
              action.consume-or-expel-window-right = [ ];
              hotkey-overlay.title = "Consume or Expel Window Right (This means stacking it to the column to the right / breaking it out of a stack to the right)";
            };

            # Column width/height switching
            "Mod+R" = {
              action.switch-preset-column-width = [ ];
              hotkey-overlay.title = "Switch Preset Column Widths (0.33, 0.5, 0.66, 0.9, 1.0) (+Shift => Switch Preset Window Heights, +Ctrl => Reset Column Height)";
            };
            "Mod+Shift+R" = { action.switch-preset-window-height = [ ]; hotkey-overlay.hidden = true; };
            "Mod+Ctrl+R" = { action.reset-window-height = [ ]; hotkey-overlay.hidden = true; };

            # Column/window sizing and positioning
            # While maximize-column leaves gaps and borders around the window,
            # maximize-window-to-edges doesn't: the window expands to the edges of the screen.
            # This bind corresponds to normal window maximizing,
            # e.g. by double-clicking on the titlebar.
            "Mod+F" = {
              action.maximize-column = [ ];
              hotkey-overlay.title = "Maximize Column (+Shift => Maximize Window to Edges, +Ctrl => Expand Column to Available Width)";
            };
            "Mod+Shift+F" = { action.fullscreen-window = [ ]; hotkey-overlay.hidden = true; };
            "Mod+Ctrl+F" = { action.expand-column-to-available-width = [ ]; hotkey-overlay.hidden = true; };
            "Mod+M" = {
              action.maximize-window-to-edges = [ ];
              hotkey-overlay.title = "Maximize Window to Edges";
            };

            # Column centering
            "Mod+C" = {
              action.center-column = [ ];
              hotkey-overlay.title = "Center Column in Output (+Ctrl => Center Visible Columns)";
            };
            "Mod+Ctrl+C" = { action.center-visible-columns = [ ]; hotkey-overlay.hidden = true; };

            # Finer width adjustments.
            # This command can also:
            # * set width in pixels: "1000"
            # * adjust width in pixels: "-5" or "+5"
            # * set width as a percentage of screen width: "25%"
            # * adjust width as a percentage of screen width: "-10%" or "+10%"
            # Pixel sizes use logical, or scaled, pixels. I.e. on an output with scale 2.0,
            # set-column-width "100" will make the column occupy 200 physical screen pixels.
            "Mod+Y" = {
              action.set-column-width = "-10%";
              hotkey-overlay.title = "Decrease Column Width by 10% (+Shift => Decrease Window Height by 10%)";
            };
            "Mod+X" = {
              action.set-column-width = "+10%";
              hotkey-overlay.title = "Increase Column Width by 10% (+Shift => Increase Window Height by 10%)";
            };

            # Finer height adjustments when in column with other windows.
            "Mod+Shift+Y" = { action.set-window-height = "-10%"; hotkey-overlay.hidden = true; };
            "Mod+Shift+X" = { action.set-window-height = "+10%"; hotkey-overlay.hidden = true; };

            # Move the focused window between the floating and the tiling layout.
            "Mod+dead_circumflex" = {
              action.toggle-window-floating = [ ];
              hotkey-overlay.title = "Toggle Window Floating/Tiling (dead_circumflex is the key above Tab ^°, +Shift => Switch Focus Between Floating and Tiling)";
            };
            "Mod+Shift+dead_circumflex" = { action.switch-focus-between-floating-and-tiling = [ ]; hotkey-overlay.hidden = true; };

            # Toggle tabbed column display mode.
            # Windows in this column will appear as vertical tabs,
            # rather than stacked on top of each other.
            "Mod+G" = {
              action.toggle-column-tabbed-display = [ ];
              hotkey-overlay.title = "Toggle Column Tabbed Display (Instead of stacked windows, show them as tabs)";
            };

            # Screenshots
            "Print" = {
              action.screenshot = [ ];
              hotkey-overlay.title = "Take Screenshot (+Ctrl => Screenshot Screen, +Alt => Screenshot Window)";
            };
            "Ctrl+Print" = { action.screenshot-screen = [ ]; hotkey-overlay.hidden = true; };
            "Alt+Print" = { action.screenshot-window = [ ]; hotkey-overlay.hidden = true; };

            # Applications such as remote-desktop clients and software KVM switches may
            # request that niri stops processing the keyboard shortcuts defined here
            # so they may, for example, forward the key presses as-is to a remote machine.
            # It's a good idea to bind an escape hatch to toggle the inhibitor,
            # so a buggy application can't hold your session hostage.
            # The allow-inhibiting=false property can be applied to other binds as well,
            # which ensures niri always processes them, even when an inhibitor is active.
            "Mod+Escape" = {
              action.toggle-keyboard-shortcuts-inhibit = [ ];
              allow-inhibiting = false;
              hotkey-overlay.title = "Toggle Keyboard Shortcuts Inhibit (Used by some applications to disable niri shortcuts while they're focused)";
            };

            # The quit action will show a confirmation dialog to avoid accidental exits.
            "Ctrl+Alt+Delete" = {
              action.quit = [ ];
              hotkey-overlay.title = "Quit Niri";
            };

            # Audio controls
            "XF86AudioRaiseVolume" = {
              action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0";
              allow-when-locked = true;
              hotkey-overlay.hidden = true;
            };
            "XF86AudioLowerVolume" = {
              action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
              allow-when-locked = true;
              hotkey-overlay.hidden = true;
            };
            "XF86AudioMute" = {
              action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
              allow-when-locked = true;
              hotkey-overlay.hidden = true;
            };
            "XF86AudioMicMute" = {
              action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
              allow-when-locked = true;
              hotkey-overlay.hidden = true;
            };

            "XF86AudioPlay" = {
              action.spawn-sh = "playerctl play-pause";
              allow-when-locked = true;
              hotkey-overlay.hidden = true;
            };
            "XF86AudioStop" = {
              action.spawn-sh = "playerctl stop";
              allow-when-locked = true;
              hotkey-overlay.hidden = true;
            };
            "XF86AudioPrev" = {
              action.spawn-sh = "playerctl previous";
              allow-when-locked = true;
              hotkey-overlay.hidden = true;
            };
            "XF86AudioNext" = {
              action.spawn-sh = "playerctl next";
              allow-when-locked = true;
              hotkey-overlay.hidden = true;
            };

            "XF86MonBrightnessUp" = {
              action.spawn = [ "brightnessctl" "--class=backlight" "set" "+10%" ];
              allow-when-locked = true;
              hotkey-overlay.hidden = true;
            };
            "XF86MonBrightnessDown" = {
              action.spawn = [ "brightnessctl" "--class=backlight" "set" "10%-" ];
              allow-when-locked = true;
              hotkey-overlay.hidden = true;
            };
          };
        };
      };

    programs.dank-material-shell = {
      enable = true;
      systemd = {
        enable = true;
        restartIfChanged = true;
      };
      niri = {
        enableSpawn = false; # DMS is autostarted by systemd

        includes = {
          enable = true; # Enable config includes hack. Enabled by default.

          override = true; # If disabled, DMS settings won't be prioritized over settings defined using niri-flake
          originalFileName = "hm"; # A new name (without extension) for the config file generated by niri-flake.
          filesToInclude = [
            "outputs"
          ];
        };
      };

      enableDynamicTheming = false;
      enableSystemMonitoring = true; # System monitoring widgets (dgop)
      enableAudioWavelength = true; # Audio visualizer (cava)
      enableCalendarEvents = true; # Calendar integration (khal)
      enableClipboardPaste = true; # Pasting items from the clipboard (wtype)

      # Configuration from settings.json
      settings = {
        currentThemeName = "custom";
        currentThemeCategory = "custom";
        customThemeFile = "${config.home.homeDirectory}/NyxOS/dms/theme.json";
        popupTransparency = 1;
        widgetBackgroundColor = "sch";
        widgetColorMode = "default";
        cornerRadius = 12;
        use24HourClock = true;
        showSeconds = true;
        useFahrenheit = false;
        nightModeEnabled = false;
        animationSpeed = 1;
        customAnimationDuration = 500;
        wallpaperFillMode = "Fill";
        blurredWallpaperLayer = false;
        blurWallpaperOnOverview = false;
        showLauncherButton = true;
        showWorkspaceSwitcher = true;
        showFocusedWindow = true;
        showWeather = false;
        showMusic = true;
        showClipboard = true;
        showCpuUsage = true;
        showMemUsage = true;
        showCpuTemp = true;
        showGpuTemp = true;
        selectedGpuIndex = 0;
        enabledGpuPciIds = [ ];
        showSystemTray = true;
        showClock = true;
        showNotificationButton = true;
        showBattery = true;
        showControlCenterButton = true;
        showCapsLockIndicator = true;
        controlCenterShowNetworkIcon = true;
        controlCenterShowBluetoothIcon = true;
        controlCenterShowAudioIcon = true;
        controlCenterShowAudioPercent = false;
        controlCenterShowVpnIcon = true;
        controlCenterShowBrightnessIcon = false;
        controlCenterShowBrightnessPercent = false;
        controlCenterShowMicIcon = false;
        controlCenterShowMicPercent = false;
        controlCenterShowBatteryIcon = false;
        controlCenterShowPrinterIcon = false;
        controlCenterShowScreenSharingIcon = true;
        showPrivacyButton = true;
        privacyShowMicIcon = false;
        privacyShowCameraIcon = false;
        privacyShowScreenShareIcon = false;
        controlCenterWidgets = [
          {
            id = "volumeSlider";
            enabled = true;
            width = 50;
          }
          {
            id = "brightnessSlider";
            enabled = true;
            width = 50;
          }
          {
            id = "wifi";
            enabled = true;
            width = 50;
          }
          {
            id = "bluetooth";
            enabled = true;
            width = 50;
          }
          {
            id = "audioOutput";
            enabled = true;
            width = 50;
          }
          {
            id = "audioInput";
            enabled = true;
            width = 50;
          }
          {
            id = "nightMode";
            enabled = true;
            width = 50;
          }
          {
            id = "darkMode";
            enabled = true;
            width = 50;
          }
        ];
        showWorkspaceIndex = true;
        showWorkspaceName = false;
        showWorkspacePadding = false;
        workspaceScrolling = false;
        showWorkspaceApps = true;
        maxWorkspaceIcons = 3;
        groupWorkspaceApps = true;
        workspaceFollowFocus = false;
        showOccupiedWorkspacesOnly = false;
        reverseScrolling = false;
        dwlShowAllTags = false;
        workspaceColorMode = "default";
        workspaceUnfocusedColorMode = "default";
        workspaceUrgentColorMode = "default";
        workspaceFocusedBorderEnabled = false;
        workspaceFocusedBorderColor = "primary";
        workspaceFocusedBorderThickness = 2;
        workspaceNameIcons = { };
        waveProgressEnabled = true;
        scrollTitleEnabled = true;
        audioVisualizerEnabled = true;
        audioScrollMode = "volume";
        clockCompactMode = false;
        focusedWindowCompactMode = false;
        runningAppsCompactMode = true;
        keyboardLayoutNameCompactMode = false;
        runningAppsCurrentWorkspace = false;
        runningAppsGroupByApp = false;
        appIdSubstitutions = [
          {
            pattern = "Spotify";
            replacement = "spotify";
            type = "exact";
          }
          {
            pattern = "beepertexts";
            replacement = "beeper";
            type = "exact";
          }
          {
            pattern = "home assistant desktop";
            replacement = "homeassistant-desktop";
            type = "exact";
          }
          {
            pattern = "com.transmissionbt.transmission";
            replacement = "transmission-gtk";
            type = "contains";
          }
          {
            pattern = "^steam_app_(\\d+)$";
            replacement = "steam_icon_$1";
            type = "regex";
          }
        ];
        centeringMode = "index";
        clockDateFormat = "";
        lockDateFormat = "";
        mediaSize = 1;
        appLauncherViewMode = "list";
        spotlightModalViewMode = "list";
        sortAppsAlphabetically = false;
        appLauncherGridColumns = 4;
        spotlightCloseNiriOverview = true;
        niriOverviewOverlayEnabled = true;
        useAutoLocation = false;
        weatherEnabled = false;
        networkPreference = "auto";
        vpnLastConnected = "";
        iconTheme = "Numix-Circle";
        launcherLogoMode = "os";
        launcherLogoColorOverride = "primary";
        launcherLogoColorInvertOnMode = false;
        launcherLogoBrightness = 0.5;
        launcherLogoContrast = 1;
        launcherLogoSizeOffset = 0;
        fontFamily = "Noto Sans";
        monoFontFamily = "JetBrainsMono Nerd Font Mono";
        fontWeight = 400;
        fontScale = 1;
        notepadUseMonospace = true;
        notepadFontFamily = "";
        notepadFontSize = 14;
        notepadShowLineNumbers = false;
        notepadTransparencyOverride = -1;
        notepadLastCustomTransparency = 0.7;
        soundsEnabled = true;
        useSystemSoundTheme = false;
        soundNewNotification = true;
        soundVolumeChanged = true;
        soundPluggedIn = true;
        acMonitorTimeout = 600;
        acLockTimeout = 900;
        acSuspendTimeout = 0;
        acSuspendBehavior = 0;
        acProfileName = "";
        batteryMonitorTimeout = 300;
        batteryLockTimeout = 900;
        batterySuspendTimeout = 0;
        batterySuspendBehavior = 0;
        batteryProfileName = "";
        batteryChargeLimit = 80;
        lockBeforeSuspend = false;
        loginctlLockIntegration = true;
        fadeToLockEnabled = true;
        fadeToLockGracePeriod = 5;
        fadeToDpmsEnabled = true;
        fadeToDpmsGracePeriod = 5;
        launchPrefix = "";
        brightnessDevicePins = { };
        wifiNetworkPins = { };
        bluetoothDevicePins = { };
        audioInputDevicePins = { };
        audioOutputDevicePins = { };
        gtkThemingEnabled = true;
        qtThemingEnabled = true;
        syncModeWithPortal = true;
        terminalsAlwaysDark = false;
        showDock = false;
        notificationOverlayEnabled = false;
        modalDarkenBackground = true;
        lockScreenShowPowerActions = true;
        lockScreenShowSystemIcons = false;
        lockScreenShowTime = true;
        lockScreenShowDate = true;
        lockScreenShowProfileImage = false;
        lockScreenShowPasswordField = true;
        enableFprint = false;
        maxFprintTries = 15;
        lockScreenActiveMonitor = "all";
        lockScreenNotificationMode = 0;
        hideBrightnessSlider = false;
        notificationTimeoutLow = 5000;
        notificationTimeoutNormal = 5000;
        notificationTimeoutCritical = 0;
        notificationCompactMode = false;
        notificationPopupPosition = 0;
        notificationHistoryEnabled = true;
        notificationHistoryMaxCount = 50;
        notificationHistoryMaxAgeDays = 7;
        notificationHistorySaveLow = true;
        notificationHistorySaveNormal = true;
        notificationHistorySaveCritical = true;
        osdAlwaysShowValue = false;
        osdPosition = 5;
        osdVolumeEnabled = true;
        osdMediaVolumeEnabled = true;
        osdBrightnessEnabled = true;
        osdIdleInhibitorEnabled = true;
        osdMicMuteEnabled = true;
        osdCapsLockEnabled = true;
        osdPowerProfileEnabled = false;
        osdAudioOutputEnabled = true;
        powerActionConfirm = true;
        powerActionHoldDuration = 0.25;
        powerMenuActions = [
          "reboot"
          "logout"
          "poweroff"
          "lock"
          "suspend"
          "restart"
        ];
        powerMenuDefaultAction = "poweroff";
        powerMenuGridLayout = false;
        updaterHideWidget = false;
        updaterUseCustomCommand = false;
        updaterCustomCommand = "";
        updaterTerminalAdditionalParams = "";
        displayNameMode = "system";
        barConfigs = [
          {
            id = "default";
            name = "Main Bar";
            enabled = true;
            position = 0;
            screenPreferences = [ "all" ];
            showOnLastDisplay = true;
            leftWidgets = [
              "launcherButton"
              "workspaceSwitcher"
              {
                id = "runningApps";
                enabled = true;
              }
            ];
            centerWidgets = [
              {
                id = "focusedWindow";
                enabled = true;
              }
              {
                id = "music";
                enabled = true;
              }
            ];
            rightWidgets = [
              {
                id = "dockerManager";
                enabled = true;
              }
              {
                id = "clipboard";
                enabled = true;
              }
              {
                id = "cpuUsage";
                enabled = true;
              }
              {
                id = "memUsage";
                enabled = true;
              }
              (lib.mkIf showBattery {
                id = "battery";
                enabled = true;
              })
              {
                id = "colorPicker";
                enabled = true;
              }
              {
                id = "notificationButton";
                enabled = true;
              }
              {
                id = "systemTray";
                enabled = true;
              }
              {
                id = "clock";
                enabled = true;
              }
              {
                id = "controlCenterButton";
                enabled = true;
              }
              {
                id = "powerMenuButton";
                enabled = true;
              }
            ];
            spacing = 4;
            innerPadding = 4;
            bottomGap = 0;
            transparency = 0.95;
            widgetTransparency = 1;
            squareCorners = false;
            noBackground = false;
            gothCornersEnabled = false;
            gothCornerRadiusOverride = false;
            gothCornerRadiusValue = 12;
            borderEnabled = false;
            borderColor = "surfaceText";
            borderOpacity = 1;
            borderThickness = 1;
            fontScale = 1;
            autoHide = false;
            autoHideDelay = 250;
            openOnOverview = false;
            visible = true;
            popupGapsAuto = true;
            popupGapsManual = 4;
            scrollYBehavior = "column";
            scrollXBehavior = "none";
            widgetOutlineEnabled = false;
            widgetOutlineColor = "primary";
          }
        ];
        builtInPluginSettings = {
          dms_settings_search = {
            trigger = "?";
          };
        };
      };

      # Configuration from session.json
      session = {
        isLightMode = false;
        doNotDisturb = false;
        wallpaperPath = "${config.home.homeDirectory}/NyxOS/images/heightlines_v3/heightlines_v3_01.png";
        perMonitorWallpaper = false;
        perModeWallpaper = false;
        wallpaperPathLight = "";
        wallpaperPathDark = "";
        monitorWallpapersLight = { };
        monitorWallpapersDark = { };
        wallpaperTransition = "fade";
        wallpaperCyclingEnabled = true;
        wallpaperCyclingMode = "interval";
        wallpaperCyclingInterval = 10;
        nightModeEnabled = false;
        nightModeTemperature = 4500;
        nightModeHighTemperature = 6500;
        nightModeAutoEnabled = true;
        nightModeAutoMode = "time";
        nightModeStartHour = 19;
        nightModeStartMinute = 0;
        nightModeEndHour = 5;
        nightModeEndMinute = 0;
        pinnedApps = [ ];
        hiddenTrayIds = [ ];
        recentColors = [ ];
        showThirdPartyPlugins = false;
        launchPrefix = "";
        lastBrightnessDevice = "";
        brightnessExponentialDevices = { };
        brightnessUserSetValues = { };
        brightnessExponentValues = { };
        selectedGpuIndex = 0;
        nvidiaGpuTempEnabled = false;
        nonNvidiaGpuTempEnabled = false;
        enabledGpuPciIds = [ ];
        wifiDeviceOverride = "";
      };

      plugins = {
        # Simply enable plugins by their ID (from the registry)
        dockerManager.enable = true;
      };
    };

    xdg = {
      mimeApps = {
        enable = lib.mkDefault true;
        defaultApplications = {
          "x-scheme-handler/kdeconnect" = "thunar.desktop";
        };
      };
      portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
          pkgs.xdg-desktop-portal-gnome
        ];
        config = {
          common.default = [ "gnome" ];
          niri = {
            "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
            "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
            "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
          };
        };
      };
    };
  };
}
