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

# Moving pipx install location for easy reference in VSCode Settings
if [ ! -d "/opt/pipx" ]; then
    echo "Creating /opt/pipx and setting up permissions..."
    sudo mkdir -p /opt/pipx/{bin,share/man}
    sudo chown -R $(whoami):admin /opt/pipx
    export PIPX_HOME="/opt/pipx"
    export PIPX_BIN_DIR="/opt/pipx/bin"
    export PIPX_MAN_DIR="/opt/pipx/share/man"
    export PATH="/opt/pipx/bin:$PATH"
else
    echo "/opt/pipx already exists. Skipping directory creation."
fi

# Update Homebrew and Upgrade any already-installed formulae
brew update
brew upgrade
brew upgrade --cask
brew cleanup

# Define an array of packages to install using Homebrew.
packages=(
    "python"
    "tcl-tk"
    "python-tk"
    "bash"
    "zsh"
    "git"
    "tree"
    "node"
    "uv"
    "pipx"
    "gh"
)

# Loop over the array to install each application.
for package in "${packages[@]}"; do
    if brew list --formula | grep -q "^$package\$"; then
        echo "$package is already installed. Skipping..."
    else
        echo "Installing $package..."
        brew install "$package"
    fi
done

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

# Git config name
current_name=$($(brew --prefix)/bin/git config --global --get user.name)
if [ -z "$current_name" ]; then
    echo "Please enter your FULL NAME for Git configuration:"
    read git_user_name
    $(brew --prefix)/bin/git config --global user.name "$git_user_name"
    echo "Git user.name has been set to $git_user_name"
else
    echo "Git user.name is already set to '$current_name'. Skipping configuration."
fi

# Git config email
current_email=$($(brew --prefix)/bin/git config --global --get user.email)
if [ -z "$current_email" ]; then
    echo "Please enter your EMAIL for Git configuration:"
    read git_user_email
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

# Install GitHub Copilot extension
$(brew --prefix)/bin/gh extension install github/gh-copilot

# Create the tutorial virtual environment I use frequently
$(brew --prefix)/bin/python3 -m venv "${HOME}/tutorial"

# Install Prettier, which I use in both VSCode and Sublime Text
$(brew --prefix)/bin/npm install --global prettier

# Install DJLint, which I use in VSCode for Django and Jinja2 Template Formatting
$(brew --prefix)/bin/pipx install djlint

# Install Ruff, which I use in VSCode for Python Formatting and Linting
$(brew --prefix)/bin/uv tool install ruff

# Define an array of applications to install using Homebrew Cask.
apps=(
    "google-chrome"
    "firefox"
    "brave-browser"
    "sublime-text"
    "visual-studio-code"
    "git-credential-manager"
    "docker"
    "spotify"
    "discord"
    "google-drive"
    "gimp"
    "vlc"
    "rectangle"
    "postman"
    "keyboardcleantool"
)

# Loop over the array to install each application.
for app in "${apps[@]}"; do
    if brew list --cask | grep -q "^$app\$"; then
        echo "$app is already installed. Skipping..."
    else
        echo "Installing $app..."
        brew install --cask "$app"
    fi
done

# Install fonts. Fonts are now available directly from Homebrew cask
fonts=(
    "font-source-code-pro"
    "font-lato"
    "font-montserrat"
    "font-nunito"
    "font-open-sans"
    "font-oswald"
    "font-poppins"
    "font-raleway"
    "font-roboto"
    "font-architects-daughter"
)

for font in "${fonts[@]}"; do
    # Check if the font is already installed
    if brew list --cask | grep -q "^$font\$"; then
        echo "$font is already installed. Skipping..."
    else
        echo "Installing $font..."
        brew install --cask "$font"
    fi
done

# Once fonts are installed, import your Terminal Profile
echo "Import your terminal settings..."
echo "Terminal -> Settings -> Profiles -> Import..."
echo "Import from ${HOME}/dotfiles/settings/CMS.terminal"
echo "Press enter to continue..."
read

# Update and clean up again for safe measure
brew update
brew upgrade
brew upgrade --cask
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
