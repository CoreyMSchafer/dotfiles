#!/usr/bin/env zsh
############################
# Sets up VS Code: installs the extensions in vscode-extensions.txt and
# symlinks settings/keybindings. Safe to re-run.
############################

set -euo pipefail

# This script's folder (:A absolute, :h parent)
SCRIPT_DIR="${0:A:h}"
source "${SCRIPT_DIR}/helpers.sh"

# Put brew (and its `code` command) on the PATH
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

if ! command -v code &>/dev/null; then
    error "The 'code' command was not found. Install VS Code first (brew.sh does this)."
    exit 1
fi

# Install missing extensions; one failure shouldn't abort the rest
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

# Symlink settings and keybindings (existing files are backed up)
VSCODE_USER_SETTINGS_DIR="${HOME}/Library/Application Support/Code/User"
mkdir -p "${VSCODE_USER_SETTINGS_DIR}"

link_with_backup "${SCRIPT_DIR}/settings/VSCode-Settings.json" "${VSCODE_USER_SETTINGS_DIR}/settings.json"
link_with_backup "${SCRIPT_DIR}/settings/VSCode-Keybindings.json" "${VSCODE_USER_SETTINGS_DIR}/keybindings.json"

info "VS Code settings and keybindings have been linked."

# Open VS Code for the account sign-ins (not on test machines)
if [[ -z "${DOTFILES_NO_INPUT:-}" ]]; then
    code "${SCRIPT_DIR}"
    pause_for "Sign in to your accounts (GitHub Copilot, etc.) within VS Code."
fi
