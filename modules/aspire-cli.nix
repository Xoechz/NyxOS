{ ... }:
{
  perSystem = { pkgs, ... }: {
    packages.aspire-cli = pkgs.callPackage ../packages/aspire-cli { };
  };

  # System Module aspire-cli: Aspire CLI package for .NET Aspire distributed applications
  flake.modules.nixos.aspire-cli = { pkgs, ... }: {
    nixpkgs.overlays = [
      (final: prev: {
        aspire-cli = final.callPackage ../packages/aspire-cli { };
      })
    ];
    environment.systemPackages = [ pkgs.aspire-cli ];
  };
}
