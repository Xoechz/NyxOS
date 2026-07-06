#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <new-version>"
  echo "Example: $0 13.5.0"
  exit 1
fi

NEW_VERSION="$1"
DIR="$(cd "$(dirname "$0")" && pwd)"
PKG_FILE="$DIR/default.nix"
DEPS_FILE="$DIR/deps.json"
FLAKE_DIR="$(dirname "$(dirname "$DIR")")"

echo "Updating aspire-cli to version $NEW_VERSION"

# Update version string in default.nix
sed -i "s/version = \".*\";/version = \"$NEW_VERSION\";/" "$PKG_FILE"

# Fetch source and compute hash
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "Fetching source for v$NEW_VERSION..."
URL="https://github.com/microsoft/aspire/archive/refs/tags/v${NEW_VERSION}.tar.gz"
NIX_HASH=$(nix hash to-sri --type sha256 "$(nix-prefetch-url --unpack "$URL")")

# Update hash in default.nix
sed -i "s|hash = \".*\";|hash = \"$NIX_HASH\";|" "$PKG_FILE"

echo "Source hash: $NIX_HASH"

# Rebuild fetch-deps derivation to get fresh script
nix build "$FLAKE_DIR#aspire-cli.fetch-deps" --no-link 2>&1

# Regenerate NuGet lockfile
echo "Regenerating NuGet lockfile..."
FETCH_DEPS_SCRIPT=$(nix eval --raw "$FLAKE_DIR#aspire-cli.fetch-deps" 2>/dev/null || true)
if [ -n "$FETCH_DEPS_SCRIPT" ]; then
  # The fetch-deps passthru may not eval directly; try running via result symlink
  if [ -L "$FLAKE_DIR/result" ]; then
    "$FLAKE_DIR/result" "$DEPS_FILE"
  else
    nix build "$FLAKE_DIR#aspire-cli.fetch-deps" -o "$TMPDIR/fetch-deps" 2>&1
    "$TMPDIR/fetch-deps" "$DEPS_FILE"
  fi
fi

echo "Done! Updated to v$NEW_VERSION"
echo
echo "Next steps:"
echo "  1. Review changes: git diff"
echo "  2. Build: nix build .#aspire-cli"
echo "  3. Commit:  git add -A && git commit -m 'aspire-cli: $NEW_VERSION'"