#!/usr/bin/env zsh
############################
# Sets up VS Code: installs the extensions listed in vscode-extensions.txt
# and symlinks settings/keybindings from this repo.
# Safe to re-run: installed extensions are skipped, and existing settings
# files are backed up before being replaced with symlinks.
############################

set -euo pipefail

SCRIPT_DIR="${0:A:h}"
source "${SCRIPT_DIR}/lib.sh"

# Make sure brew-installed apps (including the `code` command) are on the PATH
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

if ! command -v code &>/dev/null; then
    error "The 'code' command was not found. Install VS Code first (brew.sh does this)."
    exit 1
fi

# Install any extensions from vscode-extensions.txt that aren't already installed
installed_extensions=$(code --list-extensions)

while IFS= read -r extension; do
    # Skip blank lines and comments
    [[ -z "$extension" || "$extension" == \#* ]] && continue
    if grep -qixF "$extension" <<<"$installed_extensions"; then
        info "$extension is already installed. Skipping."
    else
        info "Installing $extension..."
        code --install-extension "$extension"
    fi
done <"${SCRIPT_DIR}/vscode-extensions.txt"

info "VS Code extensions have been installed."

# Symlink settings and keybindings into VS Code's user settings directory.
# Any existing files are backed up first (see link_with_backup in lib.sh).
VSCODE_USER_SETTINGS_DIR="${HOME}/Library/Application Support/Code/User"
mkdir -p "${VSCODE_USER_SETTINGS_DIR}"

link_with_backup "${SCRIPT_DIR}/settings/VSCode-Settings.json" "${VSCODE_USER_SETTINGS_DIR}/settings.json"
link_with_backup "${SCRIPT_DIR}/settings/VSCode-Keybindings.json" "${VSCODE_USER_SETTINGS_DIR}/keybindings.json"

info "VS Code settings and keybindings have been linked."

# Open VS Code to sign-in to extensions
code "${SCRIPT_DIR}"
pause_for "Login to extensions (Copilot, Grammarly, etc) within VS Code."
