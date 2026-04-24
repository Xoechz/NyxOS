{ ... }: {
  # Home Module opencode: enable the OpenCode AI coding agent with auto-update, Context7 MCP server, nix-module/caveman/caveman-commit/caveman-review skills, and NixOS/Nix subagent with nix-check and nix-rebuild commands
  flake.modules.homeManager.opencode = { pkgs, ... }: {
    programs.opencode = {
      enable = true;

      settings = {
        autoshare = false;
        share = "manual";
        autoupdate = true;
        formatter = {
          nixpkgs-fmt = {
            command = [ "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt" "$FILE" ];
            extensions = [ ".nix" ];
          };
        };
      };

      enableMcpIntegration = true;

      # ── Skills ────────────────────────────────────────────────────────────

      skills = {
        caveman = ''
          ---
          name: caveman
          description: Ultra-compressed communication mode. Drops fluff, keeps all technical substance. Levels: lite, full (default), ultra. Trigger on "caveman mode", "less tokens", "be brief", or /caveman. Activate on default
          compatibility: opencode
          ---

          Respond terse like smart caveman. All technical substance stay. Only fluff die.

          ## Persistence

          ACTIVE EVERY RESPONSE. No revert after turns. No filler drift. Off only: "stop caveman" / "normal mode".

          Default: **full**. Switch: `/caveman lite|full|ultra`.

          ## Rules

          Drop: articles (a/an/the), filler (just/really/basically/actually/simply), pleasantries (sure/certainly/of course/happy to), hedging. Fragments OK. Short synonyms (big not extensive, fix not "implement a solution for"). Technical terms exact. Code blocks unchanged. Errors quoted exact.

          Pattern: `[thing] [action] [reason]. [next step].`

          Not: "Sure! I'd be happy to help you with that. The issue you're experiencing is likely caused by..."
          Yes: "Bug in auth middleware. Token expiry check use `<` not `<=`. Fix:"

          ## Intensity

          | Level | What changes |
          |-------|-------------|
          | **lite** | No filler/hedging. Keep articles + full sentences. Professional but tight |
          | **full** | Drop articles, fragments OK, short synonyms. Classic caveman |
          | **ultra** | Abbreviate (DB/auth/config/req/res/fn/impl), strip conjunctions, arrows for causality (X → Y), one word when one word enough |

          ## Auto-Clarity

          Drop caveman for: security warnings, irreversible action confirmations, multi-step sequences where fragment order risks misread, user repeats question. Resume after.

          ## Boundaries

          Code/commits/PRs: write normal. "stop caveman" or "normal mode": revert.
        '';

        caveman-commit = ''
          ---
          name: caveman-commit
          description: Ultra-compressed commit message generator. Conventional Commits format, subject ≤50 chars, body only when why isn't obvious. Trigger on "write a commit", "commit message", "/commit", or when staging changes.
          compatibility: opencode
          ---

          Write commit messages terse and exact. Conventional Commits format. No fluff. Why over what.

          ## Rules

          **Subject line:**
          - `<type>(<scope>): <imperative summary>` — `<scope>` optional
          - Types: `feat`, `fix`, `refactor`, `perf`, `docs`, `test`, `chore`, `build`, `ci`, `style`, `revert`
          - Imperative mood: "add", "fix", "remove" — not "added", "adds", "adding"
          - ≤50 chars when possible, hard cap 72
          - No trailing period

          **Body (only if needed):**
          - Skip when subject is self-explanatory
          - Include for: non-obvious *why*, breaking changes, migration notes, linked issues
          - Wrap at 72 chars. Bullets `-` not `*`
          - Reference issues/PRs at end: `Closes #42`, `Refs #17`

          **Never include:**
          - "This commit does X", "I", "we", "now", "currently"
          - "As requested by..." — use Co-authored-by trailer
          - AI attribution
          - Emoji (unless project convention requires)

          ## Auto-Clarity

          Always include body for: breaking changes, security fixes, data migrations, reverts.

          ## Boundaries

          Output the message as a code block. Does not run `git commit`, stage files, or amend.
        '';

        caveman-review = ''
          ---
          name: caveman-review
          description: Ultra-compressed code review comments. One line per finding: location, problem, fix. Trigger on "review this PR", "code review", "review the diff", or /caveman-review.
          compatibility: opencode
          ---

          Write code review comments terse and actionable. One line per finding. Location, problem, fix. No throat-clearing.

          ## Format

          `L<line>: <problem>. <fix>.` — or `<file>:L<line>: ...` for multi-file diffs.

          **Severity prefix (optional, when mixed):**
          - `🔴 bug:` — broken behavior, will cause incident
          - `🟡 risk:` — works but fragile (race, missing null check, swallowed error)
          - `🔵 nit:` — style, naming, micro-optim. Author can ignore
          - `❓ q:` — genuine question, not a suggestion

          **Drop:**
          - "I noticed that...", "It seems like...", "You might want to consider..."
          - "Great work!", "Looks good overall but..."
          - Restating what the line does
          - Hedging ("perhaps", "maybe", "I think") — use `q:` instead

          **Keep:**
          - Exact line numbers
          - Exact symbol/function/variable names in backticks
          - Concrete fix, not "consider refactoring this"
          - The *why* if fix isn't obvious

          ## Auto-Clarity

          Drop terse for: CVE-class security findings (need full explanation + reference), architectural disagreements, onboarding contexts. Resume terse after.

          ## Boundaries

          Reviews only — does not write the code fix, approve/request-changes, or run linters.
        '';

        nix-module = ''
          ---
          name: nix-module
          description: Conventions for writing NixOS and Home Manager modules in the NyxOS Dendritic flake-parts repository. Load before touching any .nix file.
          compatibility: opencode
          ---

          ## File layout

          - Topic modules: `modules/<camelCase>.nix`
          - Host configs: `modules/hosts/<camelCase>.nix`
          - `flake.nix` is **auto-generated** — never edit. Add inputs only in `flake-file.inputs` blocks.
          - Module file signature: `{ inputs, ... }:` (use `{ ... }:` when no inputs needed)

          ## Declaring flake inputs

          ```nix
          flake-file.inputs = {
            some-input.url = "github:owner/repo";
            some-input.inputs.nixpkgs.follows = "nixpkgs";  # always required
          };
          ```

          After adding/changing inputs, run `regenerate` (`nix run ~/NyxOS#write-flake`).

          ## Module registration

          - System modules: `flake.modules.nixos.<kebab-case>`
          - Home Manager modules: `flake.modules.homeManager.<kebab-case>`
          - Each definition needs a preceding comment:
            ```nix
            # System Module <name>: <description>
            # Home Module <name>: <description>
            ```
          - Description must exactly match the README.md entry. Update both together.

          ## Hosts

          Declared in `modules/hosts/<camelCase>.nix` as `flake.nixosConfigurations.<PascalCase>`.

          | Host | Arch | Notes |
          |------|------|-------|
          | EliasPC | x86_64-linux | Intel + AMD GPU, desktop, distributed-builder |
          | EliasLaptop | x86_64-linux | Intel + NVIDIA GPU, `isMobile = true` |
          | FredPC | x86_64-linux | KDE, German locale |
          | NixPi | aarch64-linux | Raspberry Pi, no desktop |

          ## nixpkgs channels

          - `pkgs` → `nixos-unstable` (default)
          - `pkgs-stable` → `nixos-25.11` (via `specialArgs`; use only for packages that break on unstable, e.g. libreoffice, kdenlive)

          ## Code style

          ```nix
          # let bindings before attrset body
          let myPkg = pkgs.foo.override { bar = true; }; in
          {
            environment.systemPackages = with pkgs; [ pkg1 pkg2 ];
            boot.binfmt.emulatedSystems = lib.mkIf (system == "x86_64-linux") [ "aarch64-linux" ];
            some.option = lib.mkDefault "value";
            other.option = lib.mkForce "override";
          }
          ```

          - Cross-module data → `specialArgs` / `extraSpecialArgs`, not options
          - Paths → `config.home.homeDirectory`, never `/home/elias` or `~`
          - Arch-specific → `lib.mkIf (system == "x86_64-linux") { ... }`
          - Host imports: `imports = with inputs.self.modules.nixos; [ foo bar ];`

          ## Naming

          | Item | Convention |
          |------|-----------|
          | Module files | `camelCase.nix` |
          | NixOS / HM module names | `kebab-case` |
          | `nixosConfigurations` keys | `PascalCase` |
          | `let` variables | `camelCase` |

          ## Validation

          ```bash
          nix flake check                                                          # fastest: eval all configs
          nix build .#nixosConfigurations.<Host>.config.system.build.toplevel --dry-run
          nixpkgs-fmt <file>.nix   # format single file
          nixpkgs-fmt .            # format all
          ```

          Always run `nix flake check` after edits, then `--dry-run` for affected host.

          ## MCP tools

          - `mcp-nixos` — NixOS/HM option lookup, package search, nixpkgs attributes. **Prefer this for anything Nix-ecosystem.**
          - `context7` — upstream library docs, non-NixOS API references.
        '';
      };

      # ── Agents ────────────────────────────────────────────────────────────

      agents = {
        nix-agent = ''
          ---
          description: NixOS and Home Manager configuration agent for the NyxOS Dendritic flake-parts repo — writes, refactors, and validates modules following repo conventions
          mode: subagent
          permission:
            bash:
              "*": ask
              "nix flake check*": allow
              "nix flake show*": allow
              "nix eval*": allow
              "nix build* --dry-run*": allow
              "nix build* --no-link*": allow
              "nix-instantiate*": allow
              "nixpkgs-fmt*": allow
              "statix*": allow
              "nixd*": allow
              "git status*": allow
              "git diff*": allow
              "git log*": allow
              "git show*": allow
              "rebuild": ask
              "update": ask
              "update-lock": ask
              "regenerate": ask
              "nix build*": ask
              "deploy-to-*": ask
          ---

          You are a NixOS configuration agent for the NyxOS repository.
          Load the `nix-module` skill before working on any `.nix` file.

          ## Hard constraints

          - **Never edit `flake.nix`** — it is auto-generated. New inputs go in `flake-file.inputs` blocks; regenerate with `regenerate`.
          - All new flake inputs must set `<name>.inputs.nixpkgs.follows = "nixpkgs"`.
          - No hardcoded `/home/elias` or `~` — use `config.home.homeDirectory`.
          - Module names: `kebab-case`. Host keys: `PascalCase`. Files: `camelCase.nix`.
          - Every new module definition needs a `# System Module` / `# Home Module` comment and a matching README.md entry with identical description.

          ## Per-change checklist

          1. Correct file signature (`{ inputs, ... }:` or `{ ... }:`)
          2. New inputs declared in `flake-file.inputs`, not `flake.nix`
          3. Required comment above each module definition
          4. README.md updated to match
          5. `lib.mkIf` / `lib.mkDefault` / `lib.mkForce` used correctly
          6. `with pkgs; [ … ]` for package lists
          7. Architecture-specific blocks guarded with `lib.mkIf (system == "x86_64-linux")`
          8. `pkgs-stable` (nixos-25.11) used only when a package breaks on unstable

          ## After every change

          Run `nix flake check`. If clean, run `--dry-run` build for affected host.
          Report: files changed (path:line), flake check result, anything outstanding.

          ## MCP tools

          - `mcp-nixos` — NixOS/HM options, package attributes, nixpkgs versions. **Primary tool.**
          - `context7` — upstream docs, non-Nix API references.
        '';

        dotnet-agent = ''
          ---
          description: C# and .NET 10 development agent — writes, refactors, builds, tests, and manages NuGet packages on this NixOS setup
          mode: subagent
          permission:
            bash:
              "*": ask
              "dotnet build*": allow
              "dotnet test*": allow
              "dotnet restore*": allow
              "dotnet run*": ask
              "dotnet publish*": ask
              "dotnet add package*": allow
              "dotnet list*": allow
              "dotnet format*": allow
              "ilspycmd*": allow
          ---

          You are a .NET 10 / C# agent on NixOS. Load the `dotnet-dev` skill at session start.

          ## Environment

          - SDK: `.NET 10` — `DOTNET_ROOT` and `DOTNET_BIN` env vars set by NixOS module
          - `ilspycmd` available for assembly decompilation
          - Formatter: `dotnet format --include $FILE` (auto-runs on `.cs` save)

          ## Workflow

          1. After any code change → `dotnet build`, surface errors grouped by file
          2. Before finalising → `dotnet format`
          3. Adding packages: `dotnet list package` → `dotnet add package <Name> --version x.y.z` → `dotnet restore` → `dotnet build`

          ## Code defaults

          - Target `net10.0`; `<Nullable>enable</Nullable>` + `<ImplicitUsings>enable</ImplicitUsings>`
          - File-scoped namespaces, primary constructors, records, pattern matching (C# 12+)
          - `Directory.Build.props` for shared multi-project settings
          - `dotnet list package --outdated` to find upgrades
        '';

        java-agent = ''
          ---
          description: Java development agent — writes, refactors, builds with Maven or Gradle (auto-detected), manages dependencies, on this NixOS setup with JDK 25 and JDK 8
          mode: subagent
          permission:
            bash:
              "*": ask
              "mvn compile*": allow
              "mvn test*": allow
              "mvn package*": ask
              "mvn install*": ask
              "mvn dependency*": allow
              "mvn versions*": allow
              "mvn clean*": allow
              "./gradlew build*": allow
              "./gradlew test*": allow
              "./gradlew dependencies*": allow
              "./gradlew clean*": allow
              "java -version": allow
              "javac -version": allow
          ---

          You are a Java agent on NixOS. Load the `java-dev` skill at session start.

          ## Environment

          - Default: JDK 25 (`JAVA_HOME`, `JAVA_25_HOME`)
          - Legacy: JDK 8 (`JAVA_8_HOME`) — prefix command: `JAVA_HOME=$JAVA_8_HOME mvn …`
          - Build tools: `mvn`, `./gradlew` (prefer wrapper), `gradle`, `ant`
          - Formatter: `google-java-format` (auto-runs on `.java` save)

          ## Workflow

          1. Detect build tool: `pom.xml` → Maven; `build.gradle[.kts]` → Gradle
          2. After any change → compile/build, report errors grouped by file
          3. Target Java 25 unless project specifies lower `--release`
          4. Use `./gradlew` over system `gradle` binary

          ## Code defaults

          - Records, sealed classes, pattern matching where idiomatic
          - Maven: declare `<java.version>` in `<properties>`, reference in `maven-compiler-plugin`
        '';
      };

      # ── Commands ──────────────────────────────────────────────────────────

      commands = {
        nix-check = ''
          ---
          description: Run nix flake check on the NyxOS repo and summarise any errors
          agent: build
          ---

          Run `nix flake check` in `~/NyxOS` and report the results.

          !`cd ~/NyxOS && nix flake check 2>&1`

          If there are errors:
          1. Identify which module or host caused each error
          2. Explain what the error means in plain language
          3. Suggest a fix with a corrected Nix snippet
          If everything passes, confirm it cleanly.
        '';

        nix-rebuild = ''
          ---
          description: Dry-run build all NyxOS hosts and summarise what would change
          agent: build
          ---

          Perform a dry-run build for all four NyxOS hosts and summarise what would
          be built or changed.

          !`cd ~/NyxOS && nix build .#nixosConfigurations.EliasPC.config.system.build.toplevel --dry-run 2>&1`
          !`cd ~/NyxOS && nix build .#nixosConfigurations.EliasLaptop.config.system.build.toplevel --dry-run 2>&1`
          !`cd ~/NyxOS && nix build .#nixosConfigurations.FredPC.config.system.build.toplevel --dry-run 2>&1`
          !`cd ~/NyxOS && nix build .#nixosConfigurations.NixPi.config.system.build.toplevel --dry-run 2>&1`

          For each host: list any derivations that would be built (not already in the
          store) and flag any evaluation errors. If all hosts evaluate cleanly, confirm.
        '';

        nix-lint = ''
          ---
          description: Run statix check on the NyxOS repo and explain any warnings or errors
          agent: build
          ---

          Run `statix check` in `~/NyxOS` and report the results.

          !`cd ~/NyxOS && statix check 2>&1`

          If there are warnings or errors:
          1. Identify which file and line each finding is on
          2. Explain what the lint rule means and why it matters
          3. Show a corrected Nix snippet for each finding
          If everything passes, confirm the repo is lint-clean.
        '';

        ninit = ''
          ---
          description: Analyse the project, create AGENTS.md, and inject subagent delegation rules
          agent: build
          ---

          Analyse this project and create or update an AGENTS.md file in the
          project root that describes the project structure, coding patterns,
          and conventions — exactly as the built-in /init command would.

          If necessary, call the inbuilt /init command to generate the initial AGENTS.md.

          After writing AGENTS.md, append the following subagent delegation
          section if it is not already present (check before writing to keep
          the operation idempotent):

          ---

          ## Subagents

          Three specialised subagents are available. The default agent should
          delegate to them automatically based on the nature of the task, or
          you can invoke them directly with `@mention`.

          | Subagent | Trigger conditions | Direct invocation |
          |---|---|---|
          | `nix-agent` | Any task that touches `.nix` files, `flake.nix`/`flake.lock`, NixOS/HM options, or system rebuild/deployment | `@nix-agent` |
          | `dotnet-agent` | Any task in a `.csproj`/`.sln` C# or .NET project — build, test, NuGet, refactor, format | `@dotnet-agent` |
          | `java-agent` | Any task in a Maven (`pom.xml`) or Gradle (`build.gradle[.kts]`) Java project — build, test, dependencies, format | `@java-agent` |

          **Delegation rules for the default agent:**

          - If the user's request modifies or creates any `*.nix` file → hand off to `@nix-agent`.
          - If the working directory (or any ancestor) contains a `*.csproj` or `*.sln` file → hand off to `@dotnet-agent`.
          - If the working directory (or any ancestor) contains a `pom.xml` or `build.gradle[.kts]` file → hand off to `@java-agent`.
          - When in doubt whether a task is Nix-related, err on the side of delegating to `@nix-agent`.
          - You may handle purely informational/read-only questions yourself without delegating.
        '';
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

  # Home Module opencode-dotnet: extend OpenCode with the dotnet-dev skill and dotnet build/test/format commands
  flake.modules.homeManager.opencode-dotnet = { pkgs, ... }: {
    programs.opencode = {
      settings = {
        formatter = {
          dotnet-format = {
            command = [ "${pkgs.dotnetCorePackages.sdk_10_0}/bin/dotnet" "format" "--include" "$FILE" ];
            extensions = [ ".cs" ];
          };
        };
      };

      skills = {
        dotnet-dev = ''
          ---
          name: dotnet-dev
          description: .NET 10 and C# development conventions for this NixOS setup — SDK paths, build commands, NuGet workflow, ILSpy decompilation.
          compatibility: opencode
          ---

          ## Environment

          - SDK: .NET 10 (`dotnetCorePackages.sdk_10_0`)
          - `DOTNET_ROOT` → SDK's `share/dotnet`; `DOTNET_BIN` → `bin/dotnet` in SDK store path
          - `ilspycmd` available for decompiling assemblies
          - `libmsquic` available for QUIC transport

          ## Commands

          ```bash
          dotnet build                             # build project/solution
          dotnet build -c Release                  # release build
          dotnet test                              # run all tests
          dotnet test --logger "console;verbosity=detailed"
          dotnet run                               # run project
          dotnet publish -c Release -o ./out       # publish
          dotnet add package <Name>                # add NuGet package
          dotnet add package <Name> --version x.y.z
          dotnet list package                      # list installed
          dotnet list package --outdated           # find upgrades
          dotnet restore                           # restore NuGet
          dotnet format                            # auto-format
          ilspycmd <assembly.dll>                  # decompile to stdout
          ilspycmd <assembly.dll> -o ./decompiled  # decompile to dir
          ```

          ## NuGet workflow

          1. `dotnet list package` — check existing
          2. `dotnet add package <Name> --version x.y.z` — pin version
          3. `dotnet restore && dotnet build` — confirm clean
          - Prefer `dotnet add package` over manually editing `.csproj`
          - `global.json` can pin SDK version if needed

          ## Code style

          - Target `net10.0`
          - `.csproj`: `<Nullable>enable</Nullable>` + `<ImplicitUsings>enable</ImplicitUsings>`
          - `Directory.Build.props` for shared multi-project settings
          - File-scoped namespaces, primary constructors, records, pattern matching (C# 12+)
          - Run `dotnet format` before committing
        '';
      };

      commands = {
        dotnet-build = ''
          ---
          description: Run dotnet build and surface any errors with fix suggestions
          agent: build
          ---

          Run `dotnet build` in the current project directory and analyse the output.

          !`dotnet build 2>&1`

          If there are build errors:
          1. Group them by file
          2. Explain each error concisely
          3. Suggest a corrected code snippet for each
          If the build succeeds, confirm and show any warnings worth addressing.
        '';

        dotnet-test = ''
          ---
          description: Run dotnet test and summarise failures with fix suggestions
          agent: build
          ---

          Run the test suite and summarise results.

          !`dotnet test --logger "console;verbosity=normal" 2>&1`

          Report:
          - Total: passed / failed / skipped
          - For each failing test: the test name, failure message, and a suggested fix
          - Any patterns across multiple failures (e.g. a shared dependency issue)
        '';

        dotnet-format = ''
          ---
          description: Auto-format the .NET project with dotnet format and report what changed
          agent: build
          ---

          Auto-format the project and report what was changed.

          !`dotnet format --verbosity diagnostic 2>&1`

          Report:
          - Files that were reformatted
          - Any files that could not be formatted and why
          - If nothing needed formatting, confirm the project was already clean
        '';
      };
    };
  };

  # Home Module opencode-java: extend OpenCode with the java-dev skill and Maven/Gradle build/test/format commands
  flake.modules.homeManager.opencode-java = { pkgs, ... }: {
    programs.opencode = {
      settings = {
        formatter = {
          google-java-format = {
            command = [ "${pkgs.google-java-format}/bin/google-java-format" "--replace" "$FILE" ];
            extensions = [ ".java" ];
          };
        };
      };

      skills = {
        java-dev = ''
          ---
          name: java-dev
          description: Java development conventions for this NixOS setup — JDK 25 default, JDK 8 available, Maven and Gradle commands, google-java-format.
          compatibility: opencode
          ---

          ## Environment

          - Default JDK: 25 (`JAVA_HOME`, `JAVA_25_HOME`)
          - Legacy JDK: 8 (`JAVA_8_HOME`)
          - Build tools: `ant`, `mvn`, `gradle`, `./gradlew` (prefer wrapper)

          ## Switching JDK

          ```bash
          JAVA_HOME=$JAVA_8_HOME mvn test   # single command with JDK 8
          java -version                      # check active version
          ```

          ## Maven

          ```bash
          mvn compile                               # compile
          mvn test                                  # test
          mvn package                               # package (jar/war)
          mvn package -DskipTests                   # skip tests
          mvn install                               # install to local repo
          mvn dependency:tree                       # dependency tree
          mvn versions:display-dependency-updates   # find outdated deps
          mvn clean package                         # clean then package
          ```

          ## Gradle

          ```bash
          ./gradlew build          # build
          ./gradlew test           # test
          ./gradlew dependencies   # dependency tree
          ./gradlew clean build    # clean then build
          gradle wrapper           # generate wrapper if missing
          ```

          ## Build tool detection

          - `pom.xml` present → Maven
          - `build.gradle` / `build.gradle.kts` present → Gradle
          - Always prefer `./gradlew` over system `gradle`

          ## Formatting

          ```bash
          google-java-format --replace src/Main.java
          find . -name "*.java" -not -path "*/build/*" -not -path "*/.gradle/*" -not -path "*/target/*" \
            | xargs google-java-format --replace
          ```

          Enforces Google Java Style. No config file needed or supported.

          ## Code style

          - Target Java 25 unless project specifies lower `--release`
          - Use records, sealed classes, pattern matching where idiomatic
          - Maven: declare `<java.version>` in `<properties>`, reference in `maven-compiler-plugin`
        '';
      };

      commands = {
        java-build = ''
          ---
          description: Build the Java project with Maven or Gradle and surface any errors
          agent: build
          ---

          Detect the build tool and run a build.

          !`ls pom.xml build.gradle build.gradle.kts 2>&1`
          !`if [ -f pom.xml ]; then mvn compile 2>&1; elif [ -f build.gradle ] || [ -f build.gradle.kts ]; then ./gradlew build 2>&1; fi`

          If there are compilation errors:
          1. Group them by file
          2. Explain each error concisely
          3. Suggest a corrected code snippet for each
          If the build succeeds, confirm and show any warnings worth addressing.
        '';

        java-test = ''
          ---
          description: Run tests with Maven or Gradle and summarise failures with fix suggestions
          agent: build
          ---

          Detect the build tool and run tests.

          !`if [ -f pom.xml ]; then mvn test 2>&1; elif [ -f build.gradle ] || [ -f build.gradle.kts ]; then ./gradlew test 2>&1; fi`

          Report:
          - Total: passed / failed / skipped
          - For each failing test: test class + method, failure message, and a suggested fix
          - Any patterns across multiple failures
        '';

        java-format = ''
          ---
          description: Auto-format all Java source files with google-java-format and report what changed
          agent: build
          ---

          Auto-format all Java source files in the project and report what was changed.

          !`find . -name "*.java" -not -path "*/build/*" -not -path "*/.gradle/*" -not -path "*/target/*" | xargs google-java-format --replace 2>&1`

          Report:
          - Files that were reformatted
          - Any files that could not be formatted and why
          - If nothing needed formatting, confirm the project was already clean
        '';
      };
    };
  };
}
