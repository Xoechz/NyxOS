{ inputs, ... }: {
  flake-file.inputs = {
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # System Module nixIndex: configure nix-index
  flake.modules.nixos.nixIndex = { ... }: {
    imports = [ inputs.nix-index-database.nixosModules.nix-index ];

    programs.command-not-found.enable = false;
    programs.nix-index-database.comma.enable = true;
  };

  # System Module terminal: kitty + tmux(mouse mode because i am a filthy casual) + starship + direnv + fzf + eza + zsh
  flake.modules.nixos.terminal = { ... }: {
    programs.zsh.enable = true;

    home-manager.sharedModules = [
      inputs.self.modules.homeManager.terminal
    ];
  };

  # Home Module terminal: kitty + tmux(mouse mode because i am a filthy casual) + starship + direnv + fzf + eza + zsh
  flake.modules.homeManager.terminal = { config, ... }: {
    # kitty terminal
    programs.kitty = {
      enable = true;
      shellIntegration.enableZshIntegration = true;
      settings = {
        confirm_os_window_close = 0;
        dynamic_background_opacity = true;
        enable_audio_bell = false;
        mouse_hide_wait = " 10.0 ";
        window_padding_width = 10;
      };
    };

    xdg.mimeApps.defaultApplications = {
      "terminal" = "kitty.desktop";
    };

    # tmux
    programs.tmux = {
      enable = true;
      clock24 = true;
      extraConfig = '' 
        setw -g mouse on
      '';
    };

    # zsh
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting = {
        enable = true;
      };
      shellAliases = {
        ll = "eza -la --git";
        etree = "eza -T --git -a -I '.git|node_modules|bin|obj'";
        rebuild = "sudo echo Rebuilding... && nh os switch";
        update = "sudo echo Updating... && nh os switch -u";
        regen = "sudo echo Regenerating... && nix run ${config.home.homeDirectory}/NyxOS/flake.nix#write-flake";
        cleanup = "sudo nix store optimise && nh clean all";
        pm-reset = "rm ~/.local/share/plasma-manager/last_run_* && ~/.local/share/plasma-manager/run_all.sh";
        pm-rebuild = "rebuild && pm-reset";
        show-leftovers = "nix-store --gc --print-roots | egrep -v '^(/nix/var|/run/\\w+-system|\\{memory|/proc)'";
        full-rebuild = "cd ~/NyxOS && git pull && rebuild";
        full-update = "cd ~/NyxOS && git pull && update";
        deploy-to-pi = "rebuild --target-host NixPi -H NixPi";
        cat = "bat";
        dev-certs-reload = "mkdir -p ~/NyxOS/certs && dotnet dev-certs https --format PEM -ep ~/NyxOS/certs/$(hostname)-dev-cert.pem && rebuild";
      };
      history = {
        size = 10000;
        path = config.home.homeDirectory + "/zsh/history";
      };
      initContent = ''
        DISABLE_AUTO_UPDATE=true
        DISABLE_MAGIC_FUNCTIONS=true
        export "MICRO_TRUECOLOR=1"
        setopt share_history
        setopt hist_expire_dups_first
        setopt hist_ignore_dups
        setopt hist_verify
  
        # Autostart tmux
        if [ -z "$TMUX" ]; then
          tmux attach-session -t default || tmux new-session -s default
        fi
      '';
      # required for the history search to work properly
      oh-my-zsh = {
        enable = true;
        plugins = [ ];
      };
    };

    #fancy shell with starship
    programs.starship = {
      enable = true;
      enableZshIntegration = true;

      settings = {
        add_newline = false;
        format = "$shell$username$os$hostname$nix_shell$git_branch$git_commit$git_status$git_state$directory$cmd_duration$character";
        shell = {
          disabled = false;
          format = "$indicator ";
          bash_indicator = "[\\[BASH\\]]($style)";
          zsh_indicator = "[\\[ZSH\\]]($style)";
          style = "peach bold";
        };
        username = {
          show_always = true;
          format = "[$user]($style)";
          style_user = "lavender bold";
          style_root = "red bold";
        };
        os = {
          format = "[$symbol]($style)";
          style = "sapphire bold";
          disabled = false;
          symbols = {
            NixOS = " ";
          };
        };
        hostname = {
          format = "[$hostname]($style) ";
          style = "teal bold";
          ssh_only = false;
        };
        nix_shell = {
          symbol = "❄️ ";
          format = "[$symbol$name]($style) ";
          style = "sky bold";
        };
        git_branch = {
          only_attached = true;
          format = "[ $branch]($style)";
          style = "yellow bold";
        };
        git_commit = {
          only_detached = true;
          format = "[󰜘$hash]($style)";
          style = "yellow bold";
        };
        git_status = {
          format = "[\\[$all_status$ahead_behind\\]]($style) ";
          style = "flamingo bold";
        };
        git_state = {
          format = "\\([$state( $progress_current/$progress_total)]($style)\\) ";
          style = "flamingo bold";
        };
        directory = {
          format = "[ $path]($style) ";
          style = "mauve bold";
          read_only = "🔒";
          truncation_length = 10;
          truncate_to_repo = false;
        };
        cmd_duration = {
          format = "[ $duration]($style) ";
          style = "text";
        };
        character = {
          success_symbol = "[\\$](green bold)";
          error_symbol = "[X](red bold)";
        };
      };
    };

    #enable direnv
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.eza = {
      enable = true;
      enableZshIntegration = true;
      git = true;
      icons = "auto";
    };

    programs.ripgrep.enable = true;
    programs.bat.enable = true;
  };
}
