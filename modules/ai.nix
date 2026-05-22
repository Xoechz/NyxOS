{ ... }: {
  # Home Module opencode: OpenCode agent + tiered subagents, delegate/cavekit/dotnet-dev/java-dev skills, Context7/nixos/microsoft-learn MCP, nix/dotnet/java build-test-format commands
  flake.modules.homeManager.opencode = { pkgs, localLlm, lib, ... }:
    let
      models = {
        lite = "openrouter/openai/gpt-5-mini";
        medium = "openrouter/anthropic/claude-haiku-4.5";
        heavy = "openrouter/openai/gpt-5.3-codex";
        max = "openrouter/anthropic/claude-sonnet-4.6";
      };

      commonPerms = ''
        ${""}"*": ask
            "ls*": allow
            "cat*": allow
            "find*": allow
            "which*": allow
            "env": allow
            "echo*": allow
            "ps*": allow
            "df*": allow
            "du*": allow
            "rg*": allow
            "grep*": allow
            "jq*": allow
            "file*": allow
            "stat*": allow
            "wc*": allow
            "head*": allow
            "tail*": allow
            "sort*": allow
            "timeout*": allow
            "git status*": allow
            "git commit*": deny'';

      mkPrompt = path:
        builtins.replaceStrings
          [ "@@LITE_MODEL@@" "@@MEDIUM_MODEL@@" "@@HEAVY_MODEL@@" "@@MAX_MODEL@@" "@@COMMON_PERMS@@" ]
          [ models.lite models.medium models.heavy models.max commonPerms ]
          (builtins.readFile (../. + "/${path}"));
    in
    {

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
          provider = lib.mkIf localLlm {
            ollama = {
              npm = "@ai-sdk/openai-compatible";
              name = "Ollama (local)";
              options.baseURL = "http://localhost:11434/v1";
              models = {
                "qwen3.5:4b".name = "Qwen3.5 4B (lite)";
                "qwen3.5:9b".name = "Qwen3.5 9B (medium)";
              };
            };
          };
        };

        enableMcpIntegration = true;

        skills = {
          nix-module = mkPrompt "resources/skills/nix-module/SKILL.md";
          delegate = mkPrompt "resources/skills/delegate/SKILL.md";
          cavekit = mkPrompt "resources/skills/cavekit/SKILL.md";
          cavekit-build = mkPrompt "resources/skills/cavekit-build/SKILL.md";
          cavekit-check = mkPrompt "resources/skills/cavekit-check/SKILL.md";
          dotnet-dev = mkPrompt "resources/skills/dotnet-dev/SKILL.md";
          java-dev = mkPrompt "resources/skills/java-dev/SKILL.md";
          angular-dev = mkPrompt "resources/skills/angular-dev/SKILL.md";
        };

        agents = {
          nix-max = mkPrompt "resources/agents/nix-max.md";
          dotnet-max = mkPrompt "resources/agents/dotnet-max.md";
          java-max = mkPrompt "resources/agents/java-max.md";
          angular-max = mkPrompt "resources/agents/angular-max.md";
          general-max = mkPrompt "resources/agents/general-max.md";
          nix-heavy = mkPrompt "resources/agents/nix-heavy.md";
          dotnet-heavy = mkPrompt "resources/agents/dotnet-heavy.md";
          java-heavy = mkPrompt "resources/agents/java-heavy.md";
          angular-heavy = mkPrompt "resources/agents/angular-heavy.md";
          general-heavy = mkPrompt "resources/agents/general-heavy.md";
          nix-medium = mkPrompt "resources/agents/nix-medium.md";
          dotnet-medium = mkPrompt "resources/agents/dotnet-medium.md";
          java-medium = mkPrompt "resources/agents/java-medium.md";
          angular-medium = mkPrompt "resources/agents/angular-medium.md";
          general-medium = mkPrompt "resources/agents/general-medium.md";
          nix-lite = mkPrompt "resources/agents/nix-lite.md";
          dotnet-lite = mkPrompt "resources/agents/dotnet-lite.md";
          java-lite = mkPrompt "resources/agents/java-lite.md";
          angular-lite = mkPrompt "resources/agents/angular-lite.md";
          general-lite = mkPrompt "resources/agents/general-lite.md";
          manager = mkPrompt "resources/agents/manager.md";
        };

        commands = {
          nix-check = mkPrompt "resources/commands/nix-check.md";
          nix-rebuild = mkPrompt "resources/commands/nix-rebuild.md";
          nix-lint = mkPrompt "resources/commands/nix-lint.md";
          ck-spec = mkPrompt "resources/commands/ck-spec.md";
          ck-build = mkPrompt "resources/commands/ck-build.md";
          ck-check = mkPrompt "resources/commands/ck-check.md";
        };
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
