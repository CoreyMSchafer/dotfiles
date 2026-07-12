#!/usr/bin/env bash
set -e
command -v mise >/dev/null || exit 0
echo "▸ mise: Runtimes installieren…"
mise install || true
