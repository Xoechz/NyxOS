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

    # latex
    texlive.combined.scheme-full
    (python3.withPackages (ps: [ ps.pygments ]))

    graphviz
  ];

  # enable virtualbox to run windows stuff🤮 - currently not needed, but the code is kept for future use
  # virtualisation.virtualbox.host = {
  #   enable = true;
  #   package = pkgs-stable.virtualbox;
  #   enableExtensionPack = true;
  # };

  # users.extraGroups.vboxusers.members = [ "elias" ];

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
