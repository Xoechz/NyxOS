# configures dev packages
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # c and c++
    gcc
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

    # nix
    nixd
    nixpkgs-fmt

    # latex
    texlive.combined.scheme-full
    (python3.withPackages (ps: [ ps.pygments ]))
  ];
}
