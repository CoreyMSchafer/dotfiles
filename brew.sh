#!/bin/zsh

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
brew install tree

# Install MacOS Applications
brew install --cask google-chrome
brew install --cask firefox
brew install --cask brave-browser
brew install --cask sublime-text
brew install --cask virtualbox
brew install --cask sourcetree
brew install --cask spotify
brew install --cask discord
brew install --cask google-drive
brew install --cask skype
brew install --cask gimp
brew install --cask vlc
brew install --cask rectangle
brew install --cask visual-studio-code
brew install --cask postman


# Install Source Code Pro Font
brew tap homebrew/cask-fonts
brew install --cask font-source-code-pro
