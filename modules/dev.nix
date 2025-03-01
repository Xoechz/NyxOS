# configures dev packages
{ pkgs, ... }:
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
    (python3.withPackages (ps:
      [
        ps.pygments
        ps.pip
        ps.pylint
        ps.autopep8
        ps.graphviz
      ]))

    graphviz
  ];

  # enable virtualbox to run windows stuff🤮 - currently not needed, but the codtte is kept for future use
  virtualisation.virtualbox = {
    host = {
      enable = true;
      package = pkgs.virtualbox;
      enableExtensionPack = true;
    };
    guest = {
      enable = true;
      dragAndDrop = true;
    };
  };

  boot.kernelParams = [ "kvm.enable_virt_at_load=0" ];

  users.extraGroups.vboxusers.members = [ "elias" ];

  # enable docker
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  users.extraGroups.docker.members = [ "elias" ];
}
