{ ... }: {
  # Home Module opencode: OpenCode agent + tiered subagents, delegate/cavekit/dotnet-dev/java-dev skills, Context7/nixos/microsoft-learn MCP, nix/dotnet/java build-test-format commands
  flake.modules.homeManager.opencode = { pkgs, ... }: {
    programs.opencode = {
      enable = true;

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
        openrouter = {
          url = "https://mcp.openrouter.ai/mcp";
        };
      };
    };
  };
}
