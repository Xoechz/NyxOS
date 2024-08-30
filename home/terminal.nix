# kitty and direnv setup
{ lib, ... }:
{
  # zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting = {
      enable = true;
      catppuccin = {
        enable = true;
        flavor = "mocha";
      };
    };
    shellAliases = {
      ll = "ls -l";
      rebuild = "sudo nixos-rebuild switch";
      update = "sudo nixos-rebuild switch --recreate-lock-file";
    };
    history = {
      size = 10000;
      path = "/home/elias/zsh/history";
    };
    initExtraFirst = ''
      DISABLE_AUTO_UPDATE=true
      DISABLE_MAGIC_FUNCTIONS=true
      export "MICRO_TRUECOLOR=1"
    '';
    initExtra = ''
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
      format = "$shell$username❄️$hostname$nix_shell$git_branch$git_commit$git_state$git_status$directory$cmd_duration$character";
      shell = {
        disabled = false;
        format = "$indicator";
        fish_indicator = "";
        bash_indicator = "[\\[BASH\\]]($style) ";
        zsh_indicator = "[\\[ZSH\\]]($style) ";
        style = "lavender bold";
      };
      username = {
        show_always = true;
        format = "[$user]($style)";
        style_user = "peach bold";
        style_root = "red bold";
      };
      hostname = {
        format = "[$hostname]($style) ";
        style = "teal bold";
        ssh_only = false;
      };
      nix_shell = {
        symbol = "❄️";
        format = "[$symbol$name]($style) ";
        style = "sky bold";
      };
      git_branch = {
        only_attached = true;
        format = "[$branch]($style) ";
        style = "yellow bold";
      };
      git_commit = {
        only_detached = true;
        format = "[$hash]($style)";
        style = "flamingo bold";
      };
      git_state = {
        style = "sapphire bold";
      };
      git_status = {
        style = "blue bold";
      };
      directory = {
        format = "[$path]($style) ";
        style = "mauve bold";
        read_only = "🔒";
        truncation_length = 10;
        truncate_to_repo = false;
      };
      cmd_duration = {
        format = "[$duration]($style) ";
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
      background_opacity = " 0.4 ";
      background_blur = 5;
    };
  };
}


