#!/usr/bin/env zsh
############################
# Sets up a new macOS machine:
#   1. Symlinks dotfiles from this repo into $HOME
#   2. Applies macOS system settings          (macOS.sh)
#   3. Installs Homebrew packages and apps    (brew.sh + manifest files)
#   4. Sets up VS Code                        (vscode.sh)
#
# Safe to re-run: every step checks before it changes anything, and any
# existing file that would be replaced is first moved into a timestamped
# folder under ~/.dotfiles_backup/
############################

# -e: stop on the first error, -u: error on unset variables,
# -o pipefail: a pipeline fails if any command in it fails
set -euo pipefail

# The folder this script lives in (:A = absolute path, :h = parent dir).
# The shell prompts reference this repo at ~/dotfiles, so fail early
# with a clear message if it lives anywhere else.
dotfiledir="${0:A:h}"
if [[ "${dotfiledir}" != "${HOME}/dotfiles" ]]; then
    echo "This repo must live at ${HOME}/dotfiles (currently running from ${dotfiledir})." >&2
    echo "Clone it there and re-run:" >&2
    echo "  git clone https://github.com/CoreyMSchafer/dotfiles.git ~/dotfiles" >&2
    exit 1
fi

# Load shared logging + backup functions
source "${dotfiledir}/helpers.sh"

cd "${dotfiledir}"

# list of files to symlink into $HOME
files=(zshrc zprofile zprompt bashrc bash_profile bash_prompt aliases)

for file in "${files[@]}"; do
    link_with_backup "${dotfiledir}/.${file}" "${HOME}/.${file}"
done

# ~/.private holds machine-specific/private values and is intentionally not
# in version control. Create an empty one on first run so the shell files
# that source it never point at a broken link.
[[ -e "${dotfiledir}/.private" ]] || touch "${dotfiledir}/.private"
link_with_backup "${dotfiledir}/.private" "${HOME}/.private"

# Ruff (Python linter/formatter) global config
mkdir -p "${HOME}/.config/ruff"
link_with_backup "${dotfiledir}/settings/ruff.toml" "${HOME}/.config/ruff/ruff.toml"

# Run the MacOS Script
./macOS.sh

# Run the Homebrew Script
./brew.sh

# Run VS Code Script
./vscode.sh

echo ""
info "Installation Complete!"
if [[ -d "${BACKUP_DIR}" ]]; then
    info "Files replaced by this run were backed up to ${BACKUP_DIR}"
fi
