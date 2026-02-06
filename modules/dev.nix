{ ... }: {
  # System Module c: c and c++ development environment
  flake.modules.nixos.c = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
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
    ];
  };

  # System Module python: python development environment
  flake.modules.nixos.python = { pkgs, ... }:
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
      environment.systemPackages = [
        pythonWithPackages
        pkgs.graphviz
      ];
    };

  # System Module latex: latex development environment(some features need python)
  flake.modules.nixos.latex = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      texlive.combined.scheme-full
    ];
  };

  # System Module dotnet: dotnet development environment
  flake.modules.nixos.dotnet = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      dotnetCorePackages.sdk_10_0
      ilspycmd
      libmsquic
    ];

    environment.variables = {
      DOTNET_BIN = "${pkgs.dotnetCorePackages.sdk_10_0}/bin/dotnet";
      DOTNET_ROOT = "${pkgs.dotnetCorePackages.sdk_10_0}/share/dotnet";
    };
    # // TODO: merge the LD_LIBRARY_PATH with /run/current-system/sw/lib to fix libmsquic
  };

  # System Module java: java development environment
  flake.modules.nixos.java = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      jdk21
      jdk8
      ant
      maven
      gradle
    ];

    programs.java = {
      enable = true;
      package = pkgs.jdk21;
    };

    environment.variables = {
      JAVA_21_HOME = "${pkgs.jdk21.home}";
      JAVA_8_HOME = "${pkgs.jdk8.home}";
    };
  };

  # System Module android: android development environment(needs java)
  flake.modules.nixos.android = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      android-studio
      androidenv.androidPkgs.platform-tools
      android-tools
    ];

    users.extraGroups.adbusers.members = [ "elias" ];
  };

  # System Module go: go development environment
  flake.modules.nixos.go = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      go
      gopls
      delve
      golangci-lint
    ];
  };

  # System Module docker: enable and configure docker for development
  flake.modules.nixos.docker = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      # docker
      dive
    ];

    # enable docker
    virtualisation.docker = {
      enable = true;
      daemon.settings = {
        dns = [ "8.8.8.8" "8.8.4.4" ];
      };
    };

    users.extraGroups.docker.members = [ "elias" ];
  };

  # System Module devCerts: add development certificates to the system
  flake.modules.nixos.devCerts = { lib, ... }: {
    security.pki.certificates =
      let
        certsDir = ../certs;
        certFiles = builtins.readDir certsDir;
        pemFiles = lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".pem" name) certFiles;
      in
      map (name: builtins.readFile (certsDir + "/${name}")) (builtins.attrNames pemFiles);
  };

  # System Module vm: enable and configure virtual machine support for development
  flake.modules.nixos.vm = { ... }: {
    virtualisation.virtualbox = {
      host = {
        enable = true;
        enableExtensionPack = true;
      };
      guest = {
        enable = true;
        dragAndDrop = true;
      };
    };

    boot.kernelParams = [ "kvm.enable_virt_at_load=0" ];
    users.extraGroups.vboxusers.members = [ "elias" ];
  };
}
