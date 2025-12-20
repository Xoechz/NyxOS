# kitty, zsh, starship and direnv setup
{ lib, config, ... }:
{
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
      update = "sudo echo Updating... && nix flake update --flake ~/NyxOS --impure && rebuild";
      cleanup = "sudo nix store optimise && nh clean all";
      pm-reset = "rm ~/.local/share/plasma-manager/last_run_* && ~/.local/share/plasma-manager/run_all.sh";
      pm-rebuild = "rebuild && pm-reset";
      show-leftovers = "nix-store --gc --print-roots | egrep -v '^(/nix/var|/run/\\w+-system|\\{memory|/proc)'";
      full-update = "cd ~/NyxOS && git pull && update";
      ssh = "kitten ssh";
      deploy-to-pi-from-laptop = "sudo nixos-rebuild switch --target-host nixpi --build-host eliaslaptop";
      deploy-to-pi-from-pc = "sudo nixos-rebuild switch --target-host nixpi --build-host eliaspc";
      cat = "bat";
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
    '';
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

  # kitty terminal
  programs.kitty = lib.mkForce {
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
}
