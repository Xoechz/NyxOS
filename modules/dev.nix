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
  flake.modules.nixos.dotnet = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      dotnetCorePackages.sdk_10_0
      ilspycmd
      libmsquic
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

  # System Module devCerts: load all .pem certificates from the certs/ directory into the system trust store
  flake.modules.nixos.devCerts = { lib, ... }: {
    security.pki.certificates =
      let
        certsDir = ../certs;
        certFiles = builtins.readDir certsDir;
        pemFiles = lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".pem" name) certFiles;
      in
      map (name: builtins.readFile (certsDir + "/${name}")) (builtins.attrNames pemFiles);
  };

  # Home Module opencode: enable the OpenCode AI coding agent with auto-update and Context7 MCP server
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
          dotnet-format = {
            command = [ "${pkgs.dotnetCorePackages.sdk_10_0}/bin/dotnet" "format" "--include" "$FILE" ];
            extensions = [ ".cs" ];
          };
          google-java-format = {
            command = [ "${pkgs.google-java-format}/bin/google-java-format" "--replace" "$FILE" ];
            extensions = [ ".java" ];
          };
        };
      };

      enableMcpIntegration = true;

      # ── Skills ────────────────────────────────────────────────────────────
      # Loaded on-demand by agents when working in the relevant language context.

      skills = {
        nix-module = ''
          ---
          name: nix-module
          description: Conventions for writing NixOS and Home Manager modules in the NyxOS Dendritic flake-parts repository
          compatibility: opencode
          ---

          ## What I do

          Guide correct authoring of NixOS and Home Manager modules in this repo,
          including file layout, naming, the Dendritic flake-parts pattern, and
          the required README comment format.

          ## Repository conventions

          - Every topic lives in `modules/<camelCase>.nix`
          - Each module file begins with `{ inputs, ... }:` (or `{ ... }:` when no
            inputs are needed) and returns an attribute set
          - New flake inputs are declared inside `flake-file.inputs`, never in
            `flake.nix` (which is auto-generated — never edit it directly)
          - All new inputs must set `<name>.inputs.nixpkgs.follows = "nixpkgs"`
          - System modules: `flake.modules.nixos.<camelCase>`
          - Home Manager modules: `flake.modules.homeManager.<camelCase>`
          - Each module definition must be preceded by a comment:
            `# System Module <name>: <description>` or
            `# Home Module <name>: <description>`
          - The description in the comment must exactly match the entry in README.md
          - Host files live in `modules/hosts/<camelCase>.nix` and declare
            `flake.nixosConfigurations.<PascalCase>`

          ## Code style

          - Use `let … in` for local bindings before the attribute set body
          - Use `with pkgs; [ … ]` for package lists
          - Use `lib.mkIf` for conditional options
          - Use `lib.mkDefault` / `lib.mkForce` to express option priority
          - Use `config.home.homeDirectory` instead of hardcoded `~` or `/home/elias`
          - Pass cross-module data via `specialArgs` / `extraSpecialArgs`, not options
          - Architecture-specific config: `lib.mkIf (system == "x86_64-linux") { … }`

          ## Validation commands

          ```bash
          nix flake check                                                         # fastest — evaluates all configs
          nix build .#nixosConfigurations.<HostName>.config.system.build.toplevel --dry-run
          nixpkgs-fmt <file>.nix                                                  # format a single file
          nixpkgs-fmt .                                                           # format all .nix files
          ```

          ## Available hosts

          | Key | Arch | Notable |
          |-----|------|---------|
          | EliasPC | x86_64-linux | Intel CPU + AMD GPU, desktop |
          | EliasLaptop | x86_64-linux | Intel CPU + NVIDIA GPU, mobile |
          | FredPC | x86_64-linux | KDE, German locale |
          | NixPi | aarch64-linux | Raspberry Pi server, no desktop |

          ## When to use context7

          Use the `context7` MCP tool to look up NixOS options, Home Manager options,
          and nixpkgs package attributes before writing or reviewing Nix code.
        '';

        dotnet-dev = ''
          ---
          name: dotnet-dev
          description: .NET 10 and C# development conventions for this NixOS setup including SDK paths, build commands, and NuGet workflow
          compatibility: opencode
          ---

          ## What I do

          Provide .NET 10 / C# development guidance tailored to this NixOS
          environment: SDK locations, build commands, NuGet package management,
          and ILSpy decompilation.

          ## Environment

          - SDK: .NET 10 (`dotnetCorePackages.sdk_10_0`)
          - `DOTNET_ROOT` is set to the SDK's `share/dotnet` directory
          - `DOTNET_BIN` is set to `bin/dotnet` inside the SDK store path
          - `ilspycmd` is available for decompiling assemblies
          - `libmsquic` is available for QUIC transport support

          ## Common commands

          ```bash
          dotnet build                        # build current project/solution
          dotnet build -c Release             # release build
          dotnet test                         # run all tests
          dotnet test --logger "console;verbosity=detailed"
          dotnet run                          # run the project
          dotnet publish -c Release -o ./out  # publish self-contained
          dotnet add package <PackageName>    # add NuGet package
          dotnet list package                 # list installed packages
          dotnet restore                      # restore NuGet packages
          ilspycmd <assembly.dll>             # decompile an assembly to stdout
          ilspycmd <assembly.dll> -o ./decompiled  # decompile to directory
          ```

          ## NuGet workflow

          - Prefer `dotnet add package` over manually editing `.csproj`
          - Pin versions explicitly for reproducibility: `dotnet add package Foo --version 1.2.3`
          - Use `dotnet list package --outdated` to find upgrades
          - `global.json` can pin the SDK version if needed

          ## Code style defaults

          - Target `net10.0` unless compatibility with an older TFM is required
          - Use `<Nullable>enable</Nullable>` and `<ImplicitUsings>enable</ImplicitUsings>` in `.csproj` files
          - Prefer `Directory.Build.props` for shared settings in multi-project solutions
          - Prefer records, primary constructors, pattern matching, and other C# 12+ features where idiomatic
          - Prefer `file`-scoped namespaces and primary constructors (C# 12+)
          - Use `dotnet format` to auto-format before committing
        '';

        java-dev = ''
          ---
          name: java-dev
          description: Java development conventions for this NixOS setup including JDK 25 and JDK 8 paths, Maven and Gradle usage
          license: MIT
          compatibility: opencode
          ---

          ## What I do

          Provide Java development guidance tailored to this NixOS environment:
          JDK selection, Maven and Gradle build commands, and dependency management.

          ## Environment

          - Default JDK: JDK 25 (set via `programs.java.package`)
          - `JAVA_HOME` → JDK 25
          - `JAVA_25_HOME` → JDK 25 home
          - `JAVA_8_HOME` → JDK 8 home (for legacy compatibility)
          - Build tools available: `ant`, `maven` (`mvn`), `gradle`

          ## Switching JDK

          ```bash
          # Use JDK 8 for a single command
          JAVA_HOME=$JAVA_8_HOME mvn test

          # Check active Java version
          java -version
          ```

          ## Maven commands

          ```bash
          mvn compile                   # compile sources
          mvn test                      # run tests
          mvn package                   # package (jar/war)
          mvn package -DskipTests       # skip tests when packaging
          mvn install                   # install to local repo
          mvn dependency:tree           # show dependency tree
          mvn dependency:resolve        # resolve all dependencies
          mvn versions:display-dependency-updates  # find outdated deps
          mvn clean package             # clean then package
          ```

          ## Gradle commands

          ```bash
          ./gradlew build               # build
          ./gradlew test                # run tests
          ./gradlew dependencies        # show dependency tree
          ./gradlew clean build         # clean then build
          gradle wrapper                # generate wrapper if missing
          ```

          ## Detecting the build tool

          - If `pom.xml` is present → use Maven
          - If `build.gradle` or `build.gradle.kts` is present → use Gradle
          - Prefer `./gradlew` (wrapper) over the system `gradle` binary

          ## Formatting

          ```bash
          # Format a single file in-place
          google-java-format --replace src/Main.java

          # Format all Java files in the project recursively (skipping build output)
          find . -name "*.java" -not -path "*/build/*" -not -path "*/.gradle/*" -not -path "*/target/*" \
            | xargs google-java-format --replace
          ```

          `google-java-format` enforces the Google Java Style Guide.
          No configuration file is needed or supported.

          ## Code style defaults

          - Target Java 25 unless the project specifies a lower `--release` target
          - Use records, sealed classes, and pattern matching where idiomatic
          - For Maven: declare `<java.version>` in `<properties>` and reference it
            in `maven-compiler-plugin` configuration
        '';
      };

      # ── Agents ────────────────────────────────────────────────────────────

      agents = {
        nix-agent = ''
          ---
          description: NixOS and Home Manager development agent — writes, refactors, and debugs modules following NyxOS Dendritic conventions
          mode: subagent
          ---

          You are a NixOS configuration agent specialised in the Dendritic
          flake-parts pattern used by the NyxOS repository.

          Load the `nix-module` skill before working on any `.nix` file.

          When writing or editing modules, ensure:

          - Correct module file layout (`{ inputs, ... }:` / `{ ... }:`)
          - Required `# System Module` / `# Home Module` comment above each definition
          - README.md description parity with the in-file comment
          - Inputs declared in `flake-file.inputs`, never in `flake.nix`
          - All new inputs following `nixpkgs` (`<name>.inputs.nixpkgs.follows = "nixpkgs"`)
          - Correct naming conventions (camelCase modules, PascalCase host keys)
          - `lib.mkIf` / `lib.mkDefault` / `lib.mkForce` used appropriately
          - No hardcoded `/home/elias` — use `config.home.homeDirectory`
          - Architecture-specific blocks guarded with `lib.mkIf (system == "x86_64-linux")`
          - Package lists using `with pkgs; [ … ]` style

          After making any change, run `nix flake check` to confirm evaluation is
          clean, then run a `--dry-run` build for the affected host to catch build
          errors before they reach the system.

          Report:
          1. Changes made (with file path and line reference)
          2. Result of `nix flake check` / dry-run
          3. Anything that still needs attention
        '';

        dotnet-agent = ''
          ---
          description: C# and .NET 10 development agent — writes, refactors, builds, and manages NuGet dependencies
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

          You are a .NET 10 / C# development agent working on NixOS.

          Load the `dotnet-dev` skill at the start of each session.

          Your responsibilities:
          - Write and refactor idiomatic C# 12+ code targeting .NET 10
          - Manage NuGet dependencies via `dotnet add package` and `dotnet list package`
          - Run `dotnet build` after making changes and surface any errors
          - Run `dotnet format` before finalising changes
          - Use `ilspycmd` to decompile and inspect assemblies when asked
          - Prefer `<Nullable>enable</Nullable>` and nullable-aware code
          - Use primary constructors, records, and pattern matching where appropriate

          When adding NuGet packages:
          1. Check the current packages with `dotnet list package`
          2. Add with an explicit version: `dotnet add package <Name> --version x.y.z`
          3. Run `dotnet restore` then `dotnet build` to confirm it resolves cleanly

          After any code change, always run `dotnet build` and report the result.
        '';

        java-agent = ''
          ---
          description: Java development agent — writes, refactors, builds with Maven or Gradle, and manages dependencies
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

          You are a Java development agent working on NixOS with JDK 25 (default)
          and JDK 8 available for legacy compatibility.

          Load the `java-dev` skill at the start of each session.

          Your responsibilities:
          - Write and refactor idiomatic Java code (target Java 25 unless otherwise specified)
          - Detect the build tool: Maven if `pom.xml` present, Gradle if `build.gradle[.kts]` present
          - Prefer `./gradlew` over the system `gradle` binary
          - Manage dependencies and report outdated ones when asked
          - Run the appropriate build/test command after making changes

          When switching JDK versions:
          - Prefix the command with `JAVA_HOME=$JAVA_8_HOME` for JDK 8 compatibility checks

          After any code change, always run compile/build and report the result.
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

        init = ''
          ---
          description: Analyse the project, create AGENTS.md, and inject subagent delegation rules
          agent: build
          ---

          Analyse this project and create or update an AGENTS.md file in the
          project root that describes the project structure, coding patterns,
          and conventions — exactly as the built-in /init command would.

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
      };
    };
  };
}
