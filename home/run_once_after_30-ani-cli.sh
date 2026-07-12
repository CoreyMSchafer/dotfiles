#!/usr/bin/env bash
# ani-cli hat keine Brew-Formel -> offizieller Weg: Skript ins brew-bin kopieren.
set -e
command -v brew >/dev/null || exit 0
command -v ani-cli >/dev/null && exit 0   # schon installiert
echo "▸ ani-cli installieren…"
tmp="$(mktemp -d)"
git clone --depth 1 https://github.com/pystardust/ani-cli.git "$tmp"
cp "$tmp/ani-cli" "$(brew --prefix)/bin/ani-cli"
chmod +x "$(brew --prefix)/bin/ani-cli"
rm -rf "$tmp"
