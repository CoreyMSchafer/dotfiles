#!/usr/bin/env bash
############################
# Sets up an Ubuntu machine (WSL2 on the Windows box, or any Ubuntu):
#   1. Symlinks dotfiles from this repo into $HOME
#   2. Installs apt packages                   (apt.txt)
#   3. Installs uv, Node, and global npm/uv tools
#   4. Makes zsh the login shell
#
# No macOS steps, no apps, no fonts — those belong to the host (brew.sh on the
# Mac, windows/install.ps1 on Windows). Safe to re-run: steps check before
# changing anything, and replaced files are backed up to ~/.dotfiles_backup/<timestamp>/
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

# Ruff (Python linter/formatter) global config
mkdir -p "${HOME}/.config/ruff"
link_with_backup "${dotfiledir}/settings/ruff.toml" "${HOME}/.config/ruff/ruff.toml"

# bat config + color scheme (theme cache built below)
mkdir -p "${HOME}/.config/bat"
link_with_backup "${dotfiledir}/settings/bat-config" "${HOME}/.config/bat/config"
link_with_backup "${dotfiledir}/settings/bat-themes" "${HOME}/.config/bat/themes"

# Suppresses the "Last login" line in new terminal windows
touch "${HOME}/.hushlogin"

# SSH client config (personal hosts go in the untracked config.local)
mkdir -p "${HOME}/.ssh" && chmod 700 "${HOME}/.ssh"
link_with_backup "${dotfiledir}/settings/ssh-config" "${HOME}/.ssh/config"

# --- apt packages (already-installed ones are skipped by apt)
info "Updating apt..."
sudo apt-get update -qq
mapfile -t packages < <(read_manifest "${dotfiledir}/ubuntu/apt.txt")
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

# uv (Python project/tool manager) via its installer; provides ruff/ty/djlint/pre-commit below
if command -v uv >/dev/null 2>&1; then
    info "uv is already installed. Skipping."
else
    info "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# Node LTS from NodeSource's apt repo (Ubuntu's own nodejs package is years old).
# Its setup script adds the repo + signing key; apt then owns node like any other package.
if ls /etc/apt/sources.list.d/nodesource.* >/dev/null 2>&1; then # .sources (deb822) or older .list
    info "NodeSource repo is already configured. Skipping."
else
    info "Adding the NodeSource repo and installing Node LTS..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - >/dev/null
fi
sudo apt-get install -y -qq nodejs

# Global npm tools, which I use in VS Code. apt's node puts globals under
# /usr/lib (root-owned), so point npm at ~/.local instead — already on PATH.
npm config set prefix "${HOME}/.local"
npm install --global prettier # Code formatter
npm install --global eslint   # JavaScript linter

# Global uv tools, which I use in VS Code
uv tool install djlint # Django and Jinja2 template formatting
uv tool install ruff   # Python formatting and linting
uv tool install ty     # Astral's Python type checker (used alongside ruff)

# Git config (prompt only if not already set)
if [[ -z "$(git config --global --get user.name || true)" ]]; then
    read -r -p "Please enter your FULL NAME for Git configuration: " git_user_name
    git config --global user.name "$git_user_name"
    info "Git user.name has been set to ${git_user_name}"
else
    info "Git user.name is already set to '$(git config --global --get user.name)'. Skipping configuration."
fi
if [[ -z "$(git config --global --get user.email || true)" ]]; then
    read -r -p "Please enter your EMAIL for Git configuration: " git_user_email
    git config --global user.email "$git_user_email"
    info "Git user.email has been set to ${git_user_email}"
else
    info "Git user.email is already set to '$(git config --global --get user.email)'. Skipping configuration."
fi
git config --global init.defaultBranch main

# GitHub login (skipped if already authenticated, or with DOTFILES_SKIP_SIGNIN=1 on test machines)
if [[ -n "${DOTFILES_SKIP_SIGNIN:-}" ]]; then
    info "Skipping GitHub login (DOTFILES_SKIP_SIGNIN)."
elif ! gh auth status &>/dev/null; then
    info "You will need to authenticate with GitHub. Follow the prompts to login..."
    gh auth login
else
    info "Already authenticated with GitHub. Skipping login."
fi

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
