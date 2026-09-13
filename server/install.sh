#!/usr/bin/env bash
############################
# Shell setup for a server (run as your user, after server/harden.sh):
#   1. Symlinks dotfiles from this repo into $HOME
#   2. Installs the shell essentials             (apt.txt)
#   3. Makes zsh the login shell
#
# The Ubuntu dev setup (ubuntu/install.sh) is the same idea with the full
# toolchain; a server only needs the shell to feel like home. Safe to re-run:
# steps check before changing anything, and replaced files are backed up to
# ~/.dotfiles_backup/<timestamp>/
############################

# -e exit on error, -u error on unset variables, -o pipefail fail on any pipeline stage
set -euo pipefail

# The prompts hardcode ~/dotfiles, so refuse to run from anywhere else
dotfiledir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ "${dotfiledir}" != "${HOME}/dotfiles" ]]; then
    echo "This repo must live at ${HOME}/dotfiles (currently running from ${dotfiledir})." >&2
    echo "Clone it there and re-run:" >&2
    echo "  git clone https://github.com/CoreyMSchafer/dotfiles.git ~/dotfiles" >&2
    exit 1
fi

# Logging, backup-then-symlink, and manifest helpers (shared with the Mac scripts)
source "${dotfiledir}/helpers.sh"

cd "${dotfiledir}"

# Dotfiles to symlink into $HOME
files=(zshrc zprofile zprompt aliases)

for file in "${files[@]}"; do
    link_with_backup "${dotfiledir}/.${file}" "${HOME}/.${file}"
done

# ~/.private: machine-local secrets, not in version control
[[ -e "${dotfiledir}/.private" ]] || touch "${dotfiledir}/.private"
link_with_backup "${dotfiledir}/.private" "${HOME}/.private"

# bat config + color scheme (theme cache built below)
mkdir -p "${HOME}/.config/bat"
link_with_backup "${dotfiledir}/settings/bat-config" "${HOME}/.config/bat/config"
link_with_backup "${dotfiledir}/settings/bat-themes" "${HOME}/.config/bat/themes"

# Suppresses the "Last login" line in new terminal windows
touch "${HOME}/.hushlogin"

# --- apt packages (already-installed ones are skipped by apt)
info "Updating apt..."
sudo apt-get update -qq
mapfile -t packages < <(read_manifest "${dotfiledir}/server/apt.txt")
sudo apt-get install -y -qq "${packages[@]}"

# Ubuntu names two binaries differently; give them their usual names
mkdir -p "${HOME}/.local/bin"
[[ -e "${HOME}/.local/bin/bat" ]] || ln -s "$(command -v batcat)" "${HOME}/.local/bin/bat"
[[ -e "${HOME}/.local/bin/fd" ]] || ln -s "$(command -v fdfind)" "${HOME}/.local/bin/fd"
export PATH="${HOME}/.local/bin:${PATH}"

# fzf key bindings + completion: Ubuntu's package ships them as files;
# ~/.fzf.zsh (what .zshrc sources) just loads them
if [[ -f "${HOME}/.fzf.zsh" ]]; then
    info "fzf zsh integration already configured. Skipping."
else
    info "Setting up fzf zsh integration..."
    printf 'source /usr/share/doc/fzf/examples/key-bindings.zsh\nsource /usr/share/doc/fzf/examples/completion.zsh\n' > "${HOME}/.fzf.zsh"
fi

# Register the Predawn bat theme
if bat --list-themes 2>/dev/null | grep -qx "Predawn"; then
    info "bat theme cache already built. Skipping."
else
    info "Building bat's theme cache..."
    bat cache --build >/dev/null
fi

# Git config (prompt only if not already set)
if [[ -n "${DOTFILES_NO_INPUT:-}" && -z "$(git config --global --get user.name || true)" ]]; then
    warn "Git user.name not set (DOTFILES_NO_INPUT). Set it later: git config --global user.name 'Your Name'"
elif [[ -z "$(git config --global --get user.name || true)" ]]; then
    read -r -p "Please enter your FULL NAME for Git configuration: " git_user_name
    git config --global user.name "$git_user_name"
    info "Git user.name has been set to ${git_user_name}"
else
    info "Git user.name is already set to '$(git config --global --get user.name)'. Skipping configuration."
fi
if [[ -n "${DOTFILES_NO_INPUT:-}" && -z "$(git config --global --get user.email || true)" ]]; then
    warn "Git user.email not set (DOTFILES_NO_INPUT). Set it later: git config --global user.email you@example.com"
elif [[ -z "$(git config --global --get user.email || true)" ]]; then
    read -r -p "Please enter your EMAIL for Git configuration: " git_user_email
    git config --global user.email "$git_user_email"
    info "Git user.email has been set to ${git_user_email}"
else
    info "Git user.email is already set to '$(git config --global --get user.email)'. Skipping configuration."
fi
git config --global init.defaultBranch main

# Make zsh the login shell
ZSH_PATH="$(command -v zsh)"
if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$ZSH_PATH" ]]; then
    sudo chsh -s "$ZSH_PATH" "$USER" && info "Default shell changed to zsh (takes effect on next login)."
else
    info "zsh is already the default shell. Skipping configuration."
fi

echo ""
info "Installation Complete!"
if [[ -d "${BACKUP_DIR}" ]]; then
    info "Files replaced by this run were backed up to ${BACKUP_DIR}"
fi
