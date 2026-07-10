{ lib, buildDotnetModule, fetchFromGitHub, dotnetCorePackages, clang, stdenv }:

let
  dotnetRid = dotnetCorePackages.systemToDotnetRid stdenv.hostPlatform.system;
in
buildDotnetModule rec {
  pname = "aspire-cli";
  version = "13.4.6";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "aspire";
    rev = "v${version}";
    hash = "sha256-Ji35kL3478Ors02PlfS7GFoGsZgvsbcVUklzYuiIlWE=";
  };

  projectFile = "src/Aspire.Cli/Aspire.Cli.csproj";
  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = null;

  selfContainedBuild = true;

  # Hook hardcodes --no-build in publish, which causes ILC to drop .resx resources.
  # Override install to run publish without --no-build. Build phase still runs first.
  dontDotnetInstall = true;
  installPhase = ''
    runHook preInstall

    dotnet publish src/Aspire.Cli/Aspire.Cli.csproj \
      -maxcpucount:"$NIX_BUILD_CORES" \
      -p:BuildInParallel=true \
      -p:ContinuousIntegrationBuild=true \
      -p:Deterministic=true \
      -p:OverwriteReadOnlyFiles=true \
      -p:PublishAot=true \
      -p:SelfContained=true \
      --configuration Release \
      --runtime ${dotnetRid} \
      --self-contained \
      --no-restore \
      --output $out/lib/aspire-cli

    runHook postInstall
  '';

  executables = [ "aspire" ];

  nativeBuildInputs = [ clang ];

  meta = with lib; {
    description = "Aspire CLI: create, run, and manage Aspire-based distributed applications";
    homepage = "https://github.com/microsoft/aspire";
    license = licenses.mit;
    maintainers = [ ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "aspire";
  };
}
