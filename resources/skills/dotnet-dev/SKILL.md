---
name: dotnet-dev
description: .NET 10 and C# conventions — SDK paths, build commands, NuGet
compatibility: opencode
---

## Building

Do not build! Building and running tests is reserved for the developer, except when explicitly requested.

Use only the LSP for checking.

## Nuget

If a nuget package is needed or recommended. Ask the user to install it. Do not install it yourself.

## Code style

- Target `net10.0`
- `.csproj`: `<Nullable>enable</Nullable>` + `<ImplicitUsings>enable</ImplicitUsings>`
- `Directory.Build.props` for shared multi-project settings
- File-scoped namespaces, primary constructors, records, pattern matching (C# 12+)
- Run `dotnet format` before committing
- All package versions from `Directory.Packages.props` — no version attr on `<PackageReference>`
