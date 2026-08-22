#!/usr/bin/env zsh
############################
# Installs Homebrew (if needed) and everything listed in packages.txt,
# apps.txt, and fonts.txt, installs
# global npm/uv tools, and configures git, GitHub, and the default shell.
# Safe to re-run: each step checks before it changes anything.
############################

set -euo pipefail

# The folder this script lives in (:A = absolute path, :h = parent dir)
SCRIPT_DIR="${0:A:h}"
source "${SCRIPT_DIR}/helpers.sh"

# Install Homebrew if it isn't already installed
if ! command -v brew &>/dev/null; then
    info "Homebrew not installed. Installing Homebrew."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    info "Homebrew is already installed."
fi

# Put brew on the PATH for the rest of this script: `brew shellenv` prints
# export statements and eval applies them (Apple Silicon and Intel locations)
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Verify brew is now accessible
if ! command -v brew &>/dev/null; then
    error "Failed to configure Homebrew in PATH. Please add Homebrew to your PATH manually."
    exit 1
fi

# Update Homebrew and upgrade any already-installed formulae and casks
# (brew upgrade has upgraded casks by default since Homebrew 3.2)
brew update
brew upgrade --yes

# Read a manifest file's entries, skipping comments and blank lines
read_manifest() {
    grep -vE '^#|^$' "${SCRIPT_DIR}/$1"
}

# ${(f)...} splits the output into an array, one entry per line
packages=(${(f)"$(read_manifest packages.txt)"})
apps=(${(f)"$(read_manifest apps.txt)"})
fonts=(${(f)"$(read_manifest fonts.txt)"})

# Homebrew 6+ requires trusting a third-party tap before installing from it.
# Any manifest entry with a slash (e.g. charmbracelet/tap/freeze) comes from
# one, so derive the taps to trust from the manifests themselves — nothing
# to keep in sync by hand. Trusting the tap (not just the formula) also
# covers same-tap dependencies. Older Homebrew has no trust command and
# doesn't need one.
if brew trust --help &>/dev/null; then
    for pkg in "${packages[@]}" "${apps[@]}" "${fonts[@]}"; do
        if [[ "$pkg" == */* ]]; then
            brew trust "${pkg%/*}" # strip the formula name, keep user/tap
        fi
    done
fi

# brew install is idempotent — already-installed packages are skipped with a notice.
# Fully-qualified names (e.g. charmbracelet/tap/freeze) tap their tap automatically.
# --yes: don't ask for confirmation (Homebrew 6 asks by default)
# --quiet: trim the per-package output
brew install --yes --quiet "${packages[@]}"

# Install the apps (Homebrew casks)
brew install --cask --yes --quiet "${apps[@]}"

# Install fonts. Fonts are available directly from Homebrew cask
brew install --cask --yes --quiet "${fonts[@]}"

# Make Homebrew's zsh the default shell. dscl reports the real login shell —
# $SHELL can be stale inside an existing session.
BREW_ZSH="$(brew --prefix)/bin/zsh"
CURRENT_LOGIN_SHELL="$(dscl . -read "/Users/${USER}" UserShell 2>/dev/null | awk '{print $2}')"
if [[ "$CURRENT_LOGIN_SHELL" != "$BREW_ZSH" ]]; then
    # Homebrew's zsh has to be listed in /etc/shells before chsh accepts it
    if ! grep -Fxq "$BREW_ZSH" /etc/shells; then
        info "Adding Homebrew zsh to allowed shells..."
        echo "$BREW_ZSH" | sudo tee -a /etc/shells >/dev/null
    fi
    # Via sudo — chsh's own password prompt can corrupt terminal state
    # on newer macOS
    if sudo chsh -s "$BREW_ZSH" "$USER"; then
        info "Default shell changed to Homebrew zsh."
    else
        warn "Could not change the default shell. Run this yourself later: chsh -s ${BREW_ZSH}"
    fi
else
    info "Homebrew zsh is already the default shell. Skipping configuration."
fi

# chsh's password prompt can leave the terminal in a raw state (no echo,
# Enter broken); reset it so the prompts below still work
stty sane 2>/dev/null || true

# Set up fzf key bindings and completion, non-interactively.
# --no-update-rc: don't let the installer append to .zshrc (it's a symlink
# into this repo); .zshrc already sources ~/.fzf.zsh
if [[ ! -f "${HOME}/.fzf.zsh" ]]; then
    info "Setting up fzf shell integration..."
    "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc
else
    info "fzf shell integration already configured. Skipping configuration."
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

# Check if already authenticated with GitHub to avoid re-authentication prompt
if ! gh auth status &>/dev/null; then
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

# Once fonts are installed, import your Terminal Profile
pause_for "Import your terminal settings...
Terminal -> Settings -> Profiles -> Import...
Import from ${SCRIPT_DIR}/settings/CMS.terminal"

# Clean up downloads and outdated versions
brew cleanup

pause_for "Sign in to Google Chrome."
pause_for "Connect Google Account (System Settings -> Internet Accounts)."
pause_for "Sign in to Spotify."
pause_for "Sign in to Discord."
pause_for "Open Rectangle and give it necessary permissions."
pause_for "Import your Rectangle settings located in ${SCRIPT_DIR}/settings/RectangleConfig.json."
