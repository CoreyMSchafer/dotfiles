#!/usr/bin/env bash
set -e
TPM="$HOME/.tmux/plugins/tpm"
[ -d "$TPM" ] || git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM"
echo "▸ tmux: Plugins installieren…"
"$TPM/bin/install_plugins" || true
