# configures dev packages
{ pkgs, ... }:
let
  pythonWithPackages = pkgs.python3.withPackages (ps:
    [
      ps.pygments
      ps.pip
      ps.pylint
      ps.autopep8
      ps.graphviz
      ps.numpy
      ps.scikit-learn
      ps.matplotlib
      ps.networkx
      ps.pydot
      ps.dbus-python
      ps.pandas
      pkgs.glib
      pkgs.zlib
      pkgs.libGL
      pkgs.fontconfig
      pkgs.xorg.libX11
      pkgs.libxkbcommon
      pkgs.freetype
      pkgs.dbus
    ]);
in
{
  environment.systemPackages = with pkgs; [
    # c and c++
    gcc
    gnumake
    cmake
    codespell
    conan
    cppcheck
    doxygen
    gtest
    lcov
    vcpkg
    vcpkg-tool
    gdb
    pkg-config
    valgrind

    # nix
    nixd
    nixpkgs-fmt

    # latex & python(needed for latex and separatly)
    texlive.combined.scheme-full
    pythonWithPackages

    graphviz

    dotnetCorePackages.sdk_9_0

    # php
    php
    ddev
    mkcert

    # java
    jdk8
    ant
    maven
    gradle

    nodejs
  ];

  programs.java =
    {
      enable = true;
      #package = pkgs.jdk8;
      package = (pkgs.jdk21.override { enableJavaFX = true; });
    };

  # for dynamically linked executables
  programs.nix-ld.enable = true;

  # enable virtualbox to run windows stuff🤮 - currently not needed, but the code is kept for future use
  # windows is now dual booted, so no need for virtualbox
  # virtualisation.virtualbox = {
  #   host = {
  #     enable = true;
  #     package = pkgs.virtualbox;
  #     enableExtensionPack = true;
  #   };
  #   guest = {
  #     enable = true;
  #     dragAndDrop = true;
  #   };
  # };

  # boot.kernelParams = [ "kvm.enable_virt_at_load=0" ];

  # users.extraGroups.vboxusers.members = [ "elias" ];

  # enable docker
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      dns = [ "8.8.8.8" "8.8.4.4" ];
    };
  };

  users.extraGroups.docker.members = [ "elias" ];

  # Make it possible for ddev to modify the /etc/hosts file.
  # Otherwise you'll have to manually change the
  # hosts configuration after creating a new ddev project.
  environment.etc.hosts.mode = "0644";
}
