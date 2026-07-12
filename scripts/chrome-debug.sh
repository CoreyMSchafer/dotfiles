#!/usr/bin/env bash
# Startet eine ISOLIERTE Chrome-Instanz für Claude Code (Chrome DevTools MCP)
# mit Remote-Debugging auf Port 9222.
#
# WICHTIG (Sicherheit): Das ist NICHT dein normales Chrome. Eigenes Profil,
# keine ARTE-/Privat-Logins. Solange dieses Chrome läuft, ist Port 9222 lokal
# offen — jeder lokale Prozess könnte den Browser steuern. Nur für Dev/Test,
# keine sensiblen Seiten. Chrome 136+ blockt Remote-Debugging auf dem Standard-
# profil ohnehin, deshalb dieses separate Profil.
set -euo pipefail
PROFILE="$HOME/.chrome-dev-profile"
URL="${1:-http://localhost:3000}"
open -na "Google Chrome" --args \
  --remote-debugging-port=9222 \
  --user-data-dir="$PROFILE" \
  "$URL"
echo "Debug-Chrome läuft (Port 9222, Profil: $PROFILE, URL: $URL)."
echo "In Claude Code z. B.:  \"prüfe die Console-Fehler auf $URL\""
