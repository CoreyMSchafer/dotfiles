#!/usr/bin/env zsh

# Install Homebrew if it isn't already installed
if ! command -v brew &>/dev/null; then
    echo "Homebrew not installed. Installing Homebrew."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Attempt to set up Homebrew PATH automatically for this session
    if [ -x "/opt/homebrew/bin/brew" ]; then
        # For Apple Silicon Macs
        echo "Configuring Homebrew in PATH for Apple Silicon Mac..."
        export PATH="/opt/homebrew/bin:$PATH"
    fi
else
    echo "Homebrew is already installed."
fi

# Verify brew is now accessible
if ! command -v brew &>/dev/null; then
    echo "Failed to configure Homebrew in PATH. Please add Homebrew to your PATH manually."
    exit 1
fi

# Update Homebrew and Upgrade any already-installed formulae and casks
# (brew upgrade has upgraded casks by default since Homebrew 3.2)
brew update
brew upgrade
brew cleanup

# Define an array of packages to install using Homebrew.
packages=(
    "bash"
    "coreutils"
    "dust"
    "exiftool"
    "fd"
    "ffmpeg"
    "fzf"
    "gemini-cli"
    "gh"
    "git"
    "gitleaks"
    "imagemagick"
    "just"
    "node"
    "pre-commit"
    "python"
    "python-tk"
    "ripgrep"
    "tcl-tk"
    "tealdeer"
    "tree"
    "uv"
    "vhs"
    "zsh"
)

# brew install is idempotent — already-installed packages are skipped with a notice.
brew install "${packages[@]}"

# Get the path to Homebrew's zsh
BREW_ZSH="$(brew --prefix)/bin/zsh"
# Check if Homebrew's zsh is already the default shell
if [ "$SHELL" != "$BREW_ZSH" ]; then
    echo "Changing default shell to Homebrew zsh"
    # Check if Homebrew's zsh is already in allowed shells
    if ! grep -Fxq "$BREW_ZSH" /etc/shells; then
        echo "Adding Homebrew zsh to allowed shells..."
        echo "$BREW_ZSH" | sudo tee -a /etc/shells >/dev/null
    fi
    # Set the Homebrew zsh as default shell
    chsh -s "$BREW_ZSH"
    echo "Default shell changed to Homebrew zsh."
else
    echo "Homebrew zsh is already the default shell. Skipping configuration."
fi

# Set up fzf key bindings and completion
if [[ ! -f "${HOME}/.fzf.zsh" ]]; then
    echo "Setting up fzf shell integration..."
    "$(brew --prefix)/opt/fzf/install"
else
    echo "fzf shell integration already configured. Skipping configuration."
fi

# Git config name
current_name=$($(brew --prefix)/bin/git config --global --get user.name)
if [ -z "$current_name" ]; then
    echo "Please enter your FULL NAME for Git configuration:"
    read -r git_user_name
    $(brew --prefix)/bin/git config --global user.name "$git_user_name"
    echo "Git user.name has been set to $git_user_name"
else
    echo "Git user.name is already set to '$current_name'. Skipping configuration."
fi

# Git config email
current_email=$($(brew --prefix)/bin/git config --global --get user.email)
if [ -z "$current_email" ]; then
    echo "Please enter your EMAIL for Git configuration:"
    read -r git_user_email
    $(brew --prefix)/bin/git config --global user.email "$git_user_email"
    echo "Git user.email has been set to $git_user_email"
else
    echo "Git user.email is already set to '$current_email'. Skipping configuration."
fi

# Github uses "main" as the default branch name
$(brew --prefix)/bin/git config --global init.defaultBranch main

# Check if already authenticated with GitHub to avoid re-authentication prompt
if ! $(brew --prefix)/bin/gh auth status &>/dev/null; then
    echo "You will need to authenticate with GitHub. Follow the prompts to login..."
    $(brew --prefix)/bin/gh auth login
else
    echo "Already authenticated with GitHub. Skipping login."
fi

# Install Prettier, which I use in VSCode
$(brew --prefix)/bin/npm install --global prettier

# Install ESLint, which I use in VSCode
$(brew --prefix)/bin/npm install --global eslint

# Install DJLint, which I use in VSCode for Django and Jinja2 Template Formatting
$(brew --prefix)/bin/uv tool install djlint

# Install Ruff, which I use in VSCode for Python Formatting and Linting
$(brew --prefix)/bin/uv tool install ruff

# Install ty, Astral's Python type checker (used alongside ruff)
$(brew --prefix)/bin/uv tool install ty

# Define an array of applications to install using Homebrew Cask.
apps=(
    "brave-browser"
    "claude"
    "claude-code"
    "codex"
    "copilot-cli"
    "discord"
    "docker-desktop"
    "firefox"
    "gcloud-cli"
    "gimp"
    "git-credential-manager"
    "google-chrome"
    "google-drive"
    "keyboardcleantool"
    "libreoffice"
    "postman"
    "rectangle"
    "spotify"
    "visual-studio-code"
    "vlc"
)

brew install --cask "${apps[@]}"

# Install fonts. Fonts are now available directly from Homebrew cask
fonts=(
    "font-architects-daughter"
    "font-caveat"
    "font-fontawesome"
    "font-josefin-sans"
    "font-lato"
    "font-montserrat"
    "font-nunito"
    "font-open-sans"
    "font-oswald"
    "font-playfair-display"
    "font-poppins"
    "font-quicksand"
    "font-raleway"
    "font-roboto"
    "font-source-code-pro"
    "font-varela-round"
)

brew install --cask "${fonts[@]}"

# Once fonts are installed, import your Terminal Profile
echo "Import your terminal settings..."
echo "Terminal -> Settings -> Profiles -> Import..."
echo "Import from ${HOME}/dotfiles/settings/CMS.terminal"
echo "Press enter to continue..."
read

# Update and clean up again for safe measure
brew update
brew upgrade
brew cleanup

echo "Sign in to Google Chrome. Press enter to continue..."
read

echo "Connect Google Account (System Settings -> Internet Accounts). Press enter to continue..."
read

echo "Sign in to Spotify. Press enter to continue..."
read

echo "Sign in to Discord. Press enter to continue..."
read

echo "Open Rectangle and give it necessary permissions. Press enter to continue..."
read

echo "Import your Rectangle settings located in ~/dotfiles/settings/RectangleConfig.json. Press enter to continue..."
read
