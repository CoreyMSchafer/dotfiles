#!/usr/bin/env zsh
############################
# Sets up a new macOS machine:
#   1. Symlinks dotfiles from this repo into $HOME
#   2. Applies macOS system settings          (macOS.sh)
#   3. Installs Homebrew packages and apps    (brew.sh + manifest files)
#   4. Sets up VS Code                        (vscode.sh)
#
# Safe to re-run: steps check before changing anything, and replaced files
# are backed up to ~/.dotfiles_backup/<timestamp>/
############################

# -e exit on error, -u error on unset variables, -o pipefail fail on any pipeline stage
set -euo pipefail

# --no-input: never wait for a person (test machines). Skips the computer-name and
# git identity prompts, the GitHub login, and the sign-in pauses. The child scripts
# read the variable, so exporting it by hand works for them too.
if [[ "${1:-}" == "--no-input" ]]; then
    export DOTFILES_NO_INPUT=1
fi

# This script's folder (:A absolute, :h parent). The prompts hardcode
# ~/dotfiles, so refuse to run from anywhere else.
dotfiledir="${0:A:h}"
if [[ "${dotfiledir}" != "${HOME}/dotfiles" ]]; then
    echo "This repo must live at ${HOME}/dotfiles (currently running from ${dotfiledir})." >&2
    echo "Clone it there and re-run:" >&2
    echo "  git clone https://github.com/CoreyMSchafer/dotfiles.git ~/dotfiles" >&2
    exit 1
fi

# Logging + backup-then-symlink helpers
source "${dotfiledir}/helpers.sh"

cd "${dotfiledir}"

# Dotfiles to symlink into $HOME
files=(zshrc zprofile zprompt aliases)

for file in "${files[@]}"; do
    link_with_backup "${dotfiledir}/.${file}" "${HOME}/.${file}"
done

# ~/.private: machine-local secrets, not in version control. Created empty
# so the shell files that source it always have a target.
[[ -e "${dotfiledir}/.private" ]] || touch "${dotfiledir}/.private"
link_with_backup "${dotfiledir}/.private" "${HOME}/.private"

# Ruff (Python linter/formatter) global config
mkdir -p "${HOME}/.config/ruff"
link_with_backup "${dotfiledir}/settings/ruff.toml" "${HOME}/.config/ruff/ruff.toml"

# Prettier global config: any file under $HOME with no closer .prettierrc uses it
link_with_backup "${dotfiledir}/settings/prettierrc.json" "${HOME}/.prettierrc"

# Ghostty terminal config
mkdir -p "${HOME}/.config/ghostty"
link_with_backup "${dotfiledir}/settings/ghostty-config" "${HOME}/.config/ghostty/config"

# bat config + color scheme (brew.sh builds the theme cache)
mkdir -p "${HOME}/.config/bat"
link_with_backup "${dotfiledir}/settings/bat-config" "${HOME}/.config/bat/config"
link_with_backup "${dotfiledir}/settings/bat-themes" "${HOME}/.config/bat/themes"

# Suppresses the "Last login" line in new terminal windows
touch "${HOME}/.hushlogin"

# SSH client config (personal hosts go in the untracked config.local)
mkdir -p "${HOME}/.ssh" && chmod 700 "${HOME}/.ssh"
link_with_backup "${dotfiledir}/settings/ssh-config" "${HOME}/.ssh/config"

./macOS.sh
./brew.sh
./vscode.sh

echo ""
info "Installation Complete!"
if [[ -d "${BACKUP_DIR}" ]]; then
    info "Files replaced by this run were backed up to ${BACKUP_DIR}"
fi
info "Next: clone your private repos and wire up your work environment (e.g. cd ~/Work/Ops && ./bootstrap.sh)."
