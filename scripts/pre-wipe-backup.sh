#!/usr/bin/env bash
# VOR dem Neuaufsetzen auf der ALTEN Maschine ausführen.
# Prüft alle git-Repos in ~ auf ungesicherte Arbeit und sichert Nicht-Config-Daten.
set -uo pipefail
BACKUP="$HOME/mac-backup-$(date +%Y%m%d)"
mkdir -p "$BACKUP"
echo "== 1. git-Repos in ~ auf ungepushte/ungesicherte Änderungen prüfen =="
for d in "$HOME"/*/ ; do
  [ -d "$d/.git" ] || continue
  cd "$d"
  dirty="$(git status --porcelain 2>/dev/null)"
  unpushed="$(git log --branches --not --remotes --oneline 2>/dev/null | head -1)"
  if [ -n "$dirty" ] || [ -n "$unpushed" ]; then
    echo "  ⚠  $(basename "$d")  — ungesicherte Änderungen oder ungepushte Commits!"
  fi
  cd - >/dev/null
done
echo
echo "== 2. Daten (keine Config) sichern nach $BACKUP =="
for item in zk .local/share/jrnl .password-store .gnupg .ssh; do
  if [ -e "$HOME/$item" ]; then
    echo "  kopiere $item"
    rsync -a "$HOME/$item" "$BACKUP/" 2>/dev/null || cp -R "$HOME/$item" "$BACKUP/"
  fi
done
echo
echo "Sicherung unter: $BACKUP"
echo "Prüfe die ⚠-Repos oben und pushe offene Arbeit, BEVOR du wipest."
echo "Denk außerdem an: .jks-Keystores, ~/.env, lokale DB-Dumps."
