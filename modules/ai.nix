{ inputs, ... }: {
  flake-file.inputs.opencode = {
    url = "github:anomalyco/opencode";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # Home Module opencode: OpenCode agent + tiered subagents, delegate/cavekit/dotnet-dev/java-dev skills, Context7/nixos/microsoft-learn MCP, nix/dotnet/java build-test-format commands
  flake.modules.homeManager.opencode = { pkgs, ... }: {
    programs.opencode = {
      enable = true;
      package = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (
        old:
        {
          node_modules = old.node_modules.override {
            hash = "sha256-RXrwbOwbYAHuofiv5pgvXCmXlbNhOCrvLmDOT8FjiNs=";
          };
        }
      );
      settings = {
        autoshare = false;
        share = "manual";
        autoupdate = false;
        formatter = {
          nixpkgs-fmt = {
            command = [ "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt" "$FILE" ];
            extensions = [ ".nix" ];
          };
        };
      };

      enableMcpIntegration = true;

      skills = ../resources/skills;
    };

    programs.mcp = {
      enable = true;
      servers = {
        context7 = {
          url = "https://mcp.context7.com/mcp";
        };
        nixos = {
          command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
        };
        microsoft-learn = {
          url = "https://learn.microsoft.com/api/mcp";
        };
      };
    };
  };
}
