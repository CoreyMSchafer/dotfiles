#!/usr/bin/env bash
# Klont alle aktiven Repos aus repos.txt nach ~/dev — PARALLEL (xargs -P 6).
# Private Repos brauchen vorher `gh auth login`; ohne Auth schlagen sie dank
# GIT_TERMINAL_PROMPT=0 schnell fehl statt zu hängen -> nach der Anmeldung
# einfach erneut ausführen (idempotent, überspringt Vorhandenes).
set -uo pipefail
export GIT_TERMINAL_PROMPT=0
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEV="$HOME/dev"; mkdir -p "$DEV"

grep -vE '^[[:space:]]*(#|$)' "$REPO_DIR/repos.txt" \
  | DEV="$DEV" xargs -P 6 -I {} bash -c '
      url="$1"; name="$(basename "$url" .git)"; dir="$DEV/$name"
      if [ -d "$dir" ]; then echo "  ok    $name"
      else echo "  clone $name"
        git clone -q "$url" "$dir" || echo "  FAIL  $name (Auth? -> gh auth login)"
      fi' _ {}
echo "Repo-Klone fertig (~/dev)."
