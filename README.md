# NyxOS

My NixOS config

The name is inspired by the DOTA hero Nyx

![Nyx](images/dota2_nyx.png)

## Overview

### Structure (Dendric Nix Pattern)

- [flake.nix](flake.nix) => Base of the configuration
- [hosts](hosts) => Per-host setup, disks and hardware-configuration.nix
- [modules](modules) => Flake Parts modules
  - browser.nix
    - betterfox
    - firefox
    - chromium
  - utilities.nix
    - group later, most packages, git...
  - nix.nix
    - nh
    - home-manager
    - build
    - cache signing
    - nix-ld
  - editors.nix
    - vscode
    - qgis
    - inkscape
    - gimp
    - kdenlive
  - users.nix
    - elias
    - fred
    - gerhard
  - games.nix
    - steam
    - proton
    - minecraft
  - media.nix
    - spotify
    - vlc
    - discord
    - obs
    - cava
    - sailing ;)
  - office.nix
    - libreoffice
    - thunderbird
    - teams
    - pdfarranger
  - desktop.nix
    - plasmaManager
    - kde
    - catppuccin
    - basicFonts
    - fonts
    - language
  - terminal.nix
    - kitty
    - zsh
    - starship
    - direnv
    - fzf
    - eza
    - ripgrep
    - bat
    - maybe a "fancyZsh" and a "basicZsh"
    - nix-index
  - system.nix
    - grub
    - nvidia
    - amd
    - intel
    - linux kernel
    - swap
    - bluetooth
    - fwupd
    - printing
    - pipewire
    - power management
    - optimizations
  - flatpak.nix
    - flatpak
    - discover
  - network.nix
    - ssh
    - firwall
    - blocky
    - vpn
  - dev.nix
    - docker
    - python
    - c and c++
    - latex
    - dotnet
    - java
    - nodejs
    - go
    - android
    - bruno
    - devCerts
    - vm
- [images](images) => Background and ReadMe images
- [workspaces](workspaces) => Workspaces for different tasks

// TODO: Add default applications to the modules directly
// TODO: Clean imports

### Fastfetch(Laptop)

![fastfetch](images/fastfetch.png)

### Background Image(1 of 14)

![Background image](images/heightlines_v3/heightlines_v3_01.png)

### Lockscreen Image(1 of 14)

![Lockscreen image](images/heightlines_v1/HeightLinesBlue.png)
