{ lib, buildDotnetModule, fetchFromGitHub, dotnetCorePackages, clang }:

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

  dotnetInstallFlags = [ "-p:PublishAot=true" ];

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
