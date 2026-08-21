#!/usr/bin/env zsh
############################
# Sets up VS Code: installs the extensions listed in vscode-extensions.txt
# and symlinks settings/keybindings from this repo.
# Safe to re-run: installed extensions are skipped, and existing settings
# files are backed up before being replaced with symlinks.
############################

set -euo pipefail

# The folder this script lives in (:A = absolute path, :h = parent dir)
SCRIPT_DIR="${0:A:h}"
source "${SCRIPT_DIR}/helpers.sh"

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

# Install any extensions from vscode-extensions.txt that aren't already
# installed. One failing extension shouldn't abort the rest — failures are
# collected and reported at the end.
installed_extensions=$(code --list-extensions)
failed_extensions=()

while IFS= read -r extension; do
    # Skip blank lines and comments
    [[ -z "$extension" || "$extension" == \#* ]] && continue
    if grep -qixF "$extension" <<<"$installed_extensions"; then
        info "$extension is already installed. Skipping."
    else
        info "Installing $extension..."
        if ! code --install-extension "$extension"; then
            warn "Failed to install ${extension} — continuing with the rest."
            failed_extensions+=("$extension")
        fi
    fi
done <"${SCRIPT_DIR}/vscode-extensions.txt"

if (( ${#failed_extensions[@]} > 0 )); then
    warn "These extensions did not install: ${failed_extensions[*]}"
    warn "They may now be built into VS Code, renamed, or gone from the marketplace — check and update vscode-extensions.txt."
else
    info "VS Code extensions have been installed."
fi

# Symlink settings and keybindings into VS Code's user settings directory.
# Any existing files are backed up first (see link_with_backup in helpers.sh).
VSCODE_USER_SETTINGS_DIR="${HOME}/Library/Application Support/Code/User"
mkdir -p "${VSCODE_USER_SETTINGS_DIR}"

link_with_backup "${SCRIPT_DIR}/settings/VSCode-Settings.json" "${VSCODE_USER_SETTINGS_DIR}/settings.json"
link_with_backup "${SCRIPT_DIR}/settings/VSCode-Keybindings.json" "${VSCODE_USER_SETTINGS_DIR}/keybindings.json"

info "VS Code settings and keybindings have been linked."

# Open VS Code to sign-in to extensions
code "${SCRIPT_DIR}"
pause_for "Login to extensions (Copilot, Grammarly, etc) within VS Code."
