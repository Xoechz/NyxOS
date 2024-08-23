# configures dev packages
{ pkgs, ... }:
{
    environment.systemPackages = with pkgs; [
        # c and c++
    clang-tools
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
  ];
}