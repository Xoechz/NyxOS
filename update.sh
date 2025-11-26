#! /usr/bin/env bash
# This script checks if the repository is clean, then pulls the latest changes from the repo, and then builds the NixOS configurations.

test -z "$(git status --porcelain)" || { echo "Es gibt uncommitete Änderungen. Frag Elias was das heißt."; exit 1; }

git pull origin main || { echo "Fehler beim Pullen der neuesten Änderungen."; exit 1; }

nixos-rebuild switch || { echo "Fehler beim Bauen der NixOS-Konfigurationen."; exit 1; }

echo "NixOS-Konfigurationen wurden erfolgreich aktualisiert und gebaut."
exit 0