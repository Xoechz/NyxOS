{ ... }: {
  # System Module c: install GCC, CMake, Make, GDB, Valgrind, GTest, Conan, and related C/C++ tooling
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

  # System Module python: install Python 3 with scientific and GUI libraries (numpy, matplotlib, pandas, pygobject, etc.)
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

  # System Module latex: install the full TeX Live scheme for LaTeX document authoring
  flake.modules.nixos.latex = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      texlive.combined.scheme-full
    ];
  };

  # System Module dotnet: install .NET 10 SDK with ILSpy and set DOTNET_ROOT/DOTNET_BIN environment variables
  flake.modules.nixos.dotnet = { pkgs, config, ... }: {
    environment.systemPackages = with pkgs; [
      dotnetCorePackages.sdk_10_0
      ilspycmd
      libmsquic

      # profiling
      config.boot.kernelPackages.perf
      lttng-tools
      babeltrace
    ];

    environment.variables = {
      DOTNET_BIN = "${pkgs.dotnetCorePackages.sdk_10_0}/bin/dotnet";
      DOTNET_ROOT = "${pkgs.dotnetCorePackages.sdk_10_0}/share/dotnet";
    };
    # previous library path problems should be resolved by disabling jack
  };

  # System Module java: install JDK 25 and JDK 8 with Ant, Maven, and Gradle; sets JAVA_25_HOME and JAVA_8_HOME
  flake.modules.nixos.java = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      jdk25
      jdk8
      ant
      maven
      gradle
      google-java-format
    ];

    programs.java = {
      enable = true;
      package = pkgs.jdk25;
    };

    environment.variables = {
      JAVA_25_HOME = "${pkgs.jdk25.home}";
      JAVA_8_HOME = "${pkgs.jdk8.home}";
    };
  };

  # System Module android: install Android Studio, SDK platform-tools, and adb; adds elias to the adbusers group
  flake.modules.nixos.android = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      android-studio
      androidenv.androidPkgs.platform-tools
      android-tools
    ];

    users.extraGroups.adbusers.members = [ "elias" ];
  };

  # System Module go: install the Go toolchain with gopls, Delve debugger, and golangci-lint
  flake.modules.nixos.go = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      go
      gopls
      delve
      golangci-lint
    ];
  };

  # System Module dev-certs: load all .pem certificates from the certs/ directory into the system trust store
  flake.modules.nixos.dev-certs = { lib, ... }: {
    security.pki.certificates =
      let
        certsDir = ../certs;
        certFiles = builtins.readDir certsDir;
        pemFiles = lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".pem" name) certFiles;
      in
      map (name: builtins.readFile (certsDir + "/${name}")) (builtins.attrNames pemFiles);
  };

}
