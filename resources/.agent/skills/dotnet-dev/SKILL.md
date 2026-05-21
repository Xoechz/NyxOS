---
name: dotnet-dev
description: .NET 10 and C# conventions — SDK paths, build commands, NuGet
compatibility: opencode
---

## Commands

```bash
dotnet build                             # build project/solution
dotnet build -c Release                  # release build
dotnet test                              # run all tests
dotnet test --logger "console;verbosity=detailed"
dotnet run                               # run project
dotnet add package <Name>                # add NuGet package
dotnet add package <Name> --version x.y.z
dotnet list package                      # list installed
dotnet list package --outdated           # find upgrades
dotnet restore                           # restore NuGet
dotnet format                            # auto-format
```

## NuGet workflow

1. `dotnet list package`
2. `dotnet add package <Name> --version x.y.z`
3. `dotnet restore && dotnet build`
- Prefer `dotnet add package` over manual `.csproj` edits

## Code style

- Target `net10.0`
- `.csproj`: `<Nullable>enable</Nullable>` + `<ImplicitUsings>enable</ImplicitUsings>`
- `Directory.Build.props` for shared multi-project settings
- File-scoped namespaces, primary constructors, records, pattern matching (C# 12+)
- Run `dotnet format` before committing
- All package versions from `Directory.Packages.props` — no version attr on `<PackageReference>`
