#!/usr/bin/env zsh

# Check if Homebrew is installed
if ! command -v brew &> /dev/null
then
    echo "Homebrew not installed. Installing Homebrew."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi

# Update Homebrew and Upgrade any already-installed formulae
brew update
brew upgrade

# Install Brew Packages
brew install python
brew install bash
brew install zsh
brew install tree

# Set the Homebrew zsh as default shell
echo "$(brew --prefix)/bin/zsh" | sudo tee -a /etc/shells >/dev/null
chsh -s "$(brew --prefix)/bin/zsh"

# Define an array of applications to install using Homebrew Cask.
apps=(
    "google-chrome"
    "firefox"
    "brave-browser"
    "sublime-text"
    "visual-studio-code"
    "virtualbox"
    "spotify"
    "discord"
    "google-drive"
    "gimp"
    "vlc"
    "rectangle"
    "postman"
)

# Loop over the array to install each application.
for app in "${apps[@]}"; do
    brew install --cask "$app"
done

# Install Source Code Pro Font
brew tap homebrew/cask-fonts
brew install --cask font-source-code-pro
