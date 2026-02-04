# configures dev packages
{ pkgs, lib, config, ... }:
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
      ps.pygobject3
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
    gdb
    pkg-config
    valgrind

    # latex & python(needed for latex and separatly)
    texlive.combined.scheme-full
    pythonWithPackages

    graphviz

    # dotnet
    dotnetCorePackages.sdk_10_0
    ilspycmd
    libmsquic

    # java
    jdk21
    jdk8
    ant
    maven
    gradle

    nodejs

    # go
    go
    gopls
    delve
    golangci-lint

    # http testing
    bruno

    # android
    android-studio
    androidenv.androidPkgs.platform-tools
    android-tools
  ];

  programs.java = {
    enable = true;
    package = pkgs.jdk21;
  };

  environment.variables = {
    # set the default java version to 21
    JAVA_21_HOME = "${pkgs.jdk21.home}";
    JAVA_8_HOME = "${pkgs.jdk8.home}";
    DOTNET_BIN = "${pkgs.dotnetCorePackages.sdk_10_0}/bin/dotnet";
    DOTNET_ROOT = "${pkgs.dotnetCorePackages.sdk_10_0}/share/dotnet";
    # Combine required library search paths; force to avoid conflicts with other modules
    LD_LIBRARY_PATH = lib.mkForce (builtins.concatStringsSep ":" [
      "/run/current-system/sw/lib" # base system libs
      "${config.services.pipewire.package.jack}/lib" # pipewire jack (was defined elsewhere causing conflict)
    ]);
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

  # android usb debugging
  users.extraGroups.adbusers.members = [ "elias" ];

  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };

  # certificates for https development
  security.pki.certificates =
    let
      certsDir = ../certs;
      certFiles = builtins.readDir certsDir;
      pemFiles = lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".pem" name) certFiles;
    in
    map (name: builtins.readFile (certsDir + "/${name}")) (builtins.attrNames pemFiles);
}
