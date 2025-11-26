#! /usr/bin/env bash
# This script checks if the repository is clean, then pulls the latest changes from the repo, and then builds the NixOS configurations.

test -z "$(git status --porcelain)" || { echo "Es gibt uncommitete Änderungen. Frag Elias was das heißt."; exit 1; }

# cancel if no changes to pull
git fetch origin
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse @{u})

if [ "$LOCAL" != "$REMOTE" ]; then
  git pull origin main || { echo "Fehler beim Pullen der neuesten Änderungen."; exit 1; }

    nixos-rebuild switch || { echo "Fehler beim Bauen der NixOS-Konfigurationen."; exit 1; }

    echo "NixOS-Konfigurationen wurden erfolgreich aktualisiert und gebaut."
    exit 0
fi

echo "Keine neuen Änderungen zum Pullen."
exit 0