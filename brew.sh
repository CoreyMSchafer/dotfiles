#!/usr/bin/env zsh
############################
# Installs Homebrew, the manifests (packages/apps/fonts.txt), and global
# npm/uv tools, then configures git, GitHub, and the default shell.
# Safe to re-run.
############################

set -euo pipefail

# This script's folder (:A absolute, :h parent)
SCRIPT_DIR="${0:A:h}"
source "${SCRIPT_DIR}/helpers.sh"

# Put brew on this script's PATH (Apple Silicon or Intel). Runs before the
# install check so a re-run from a pre-Homebrew shell still finds it.
brew_shellenv() {
    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
}
brew_shellenv

# Install Homebrew if it isn't already installed
if ! command -v brew &>/dev/null; then
    info "Homebrew not installed. Installing Homebrew."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew_shellenv
else
    info "Homebrew is already installed."
fi

# Verify brew is now accessible
if ! command -v brew &>/dev/null; then
    error "Failed to configure Homebrew in PATH. Please add Homebrew to your PATH manually."
    exit 1
fi

# Update Homebrew and upgrade everything installed (casks included)
brew update
brew upgrade --yes

# ${(f)...} splits the output into an array, one entry per line
packages=(${(f)"$(read_manifest "${SCRIPT_DIR}/packages.txt")"})
apps=(${(f)"$(read_manifest "${SCRIPT_DIR}/apps.txt")"})
fonts=(${(f)"$(read_manifest "${SCRIPT_DIR}/fonts.txt")"})

# Homebrew 6+ requires trusting third-party taps first. Entries with a slash
# (e.g. charmbracelet/tap/freeze) come from one, so derive the taps from the
# manifests. Older Homebrew has no trust command and doesn't need one.
if brew trust --help &>/dev/null; then
    for pkg in "${packages[@]}" "${apps[@]}" "${fonts[@]}"; do
        if [[ "$pkg" == */* ]]; then
            brew trust "${pkg%/*}" # strip the formula name, keep user/tap
        fi
    done
fi

# Install only what's missing; `brew upgrade` above already handled updates.
# Without this, `brew install` re-downloads every `version :latest` cask (the fonts).
export HOMEBREW_NO_INSTALL_UPGRADE=1

# Already-installed packages are skipped. --yes: skip Homebrew 6's
# confirmation prompts; --quiet: trim per-package output
brew install --yes --quiet "${packages[@]}"

# Install the apps (Homebrew casks)
brew install --cask --yes --quiet "${apps[@]}"

# Install the fonts (Homebrew casks)
brew install --cask --yes --quiet "${fonts[@]}"

# Make Homebrew's zsh the login shell (dscl reports the real one; $SHELL can be stale)
BREW_ZSH="$(brew --prefix)/bin/zsh"
CURRENT_LOGIN_SHELL="$(dscl . -read "/Users/${USER}" UserShell 2>/dev/null | awk '{print $2}')"
if [[ "$CURRENT_LOGIN_SHELL" != "$BREW_ZSH" ]]; then
    # Homebrew's zsh has to be listed in /etc/shells before chsh accepts it
    if ! grep -Fxq "$BREW_ZSH" /etc/shells; then
        info "Adding Homebrew zsh to allowed shells..."
        echo "$BREW_ZSH" | sudo tee -a /etc/shells >/dev/null
    fi
    # Via sudo: chsh's own password prompt can corrupt the terminal on newer macOS
    if sudo chsh -s "$BREW_ZSH" "$USER"; then
        info "Default shell changed to Homebrew zsh."
    else
        warn "Could not change the default shell. Run this yourself later: chsh -s ${BREW_ZSH}"
    fi
else
    info "Homebrew zsh is already the default shell. Skipping configuration."
fi

# Password prompts can leave the terminal raw on newer macOS; reset it
stty sane 2>/dev/null || true

# fzf key bindings + completion. --no-update-rc: .zshrc already sources
# ~/.fzf.zsh (and it's a symlink into this repo)
if [[ ! -f "${HOME}/.fzf.zsh" ]]; then
    info "Setting up fzf shell integration..."
    "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish
else
    info "fzf shell integration already configured. Skipping configuration."
fi

# Register the Predawn theme linked by install.sh
if bat --list-themes 2>/dev/null | grep -qx "Predawn"; then
    info "bat theme cache already built. Skipping."
else
    info "Building bat's theme cache..."
    bat cache --build >/dev/null
fi

# Git config name (prompt only if not already set)
if [[ -z "$(git config --global --get user.name || true)" ]]; then
    read -r "git_user_name?Please enter your FULL NAME for Git configuration: "
    git config --global user.name "$git_user_name"
    info "Git user.name has been set to ${git_user_name}"
else
    info "Git user.name is already set to '$(git config --global --get user.name)'. Skipping configuration."
fi

# Git config email (prompt only if not already set)
if [[ -z "$(git config --global --get user.email || true)" ]]; then
    read -r "git_user_email?Please enter your EMAIL for Git configuration: "
    git config --global user.email "$git_user_email"
    info "Git user.email has been set to ${git_user_email}"
else
    info "Git user.email is already set to '$(git config --global --get user.email)'. Skipping configuration."
fi

# Github uses "main" as the default branch name
git config --global init.defaultBranch main

# GitHub login (skipped if already authenticated, or with DOTFILES_SKIP_SIGNIN on test machines)
if [[ -n "${DOTFILES_SKIP_SIGNIN:-}" ]]; then
    info "Skipping GitHub login (DOTFILES_SKIP_SIGNIN)."
elif ! gh auth status &>/dev/null; then
    info "You will need to authenticate with GitHub. Follow the prompts to login..."
    gh auth login
else
    info "Already authenticated with GitHub. Skipping login."
fi

# Global npm tools, which I use in VSCode
npm install --global prettier # Code formatter
npm install --global eslint   # JavaScript linter

# Global uv tools, which I use in VSCode
uv tool install djlint # Django and Jinja2 template formatting
uv tool install ruff   # Python formatting and linting
uv tool install ty     # Astral's Python type checker (used alongside ruff)

# Clean up downloads and outdated versions
brew cleanup

pause_for "Sign in to Google Chrome."
pause_for "Connect Google Account (System Settings -> Internet Accounts)."
pause_for "Sign in to Spotify."
pause_for "Sign in to Discord."
pause_for "Open Rectangle and give it necessary permissions."
pause_for "Import your Rectangle settings located in ${SCRIPT_DIR}/settings/RectangleConfig.json."
