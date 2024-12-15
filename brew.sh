#!/usr/bin/env bash

brew tap leoafarias/fvm

# Install Brew Packages
brew install python
brew install tree
brew install openjdk
# Install flutter
brew install fvm
fvm install stable
fvm global
echo 'export PATH="$PATH":"$HOME/.pub-cache/bin"' >> ~/.zshrc
echo 'export PATH="$PATH":"$HOME/.pub-cache/bin"' >> ~/.bashrc


CASKS=(
    google-chrome
    firefox
    sublime-text
    virtualbox
    sourcetree
    spotify
    discord
    google-backup-and-sync
    skype
    gimp
    vlc
    hyperdock
    font-source-code-pro
    slack
    font-fira-code 
    intellij-idea-ce
    visual-studio-code
    steam
    docker
    alfred 
    1password
    phpstorm
    macdown
)

for app in "${CASKS[@]}"
do
   echo "brew install $app on your MacOS."
   brew install --cask $app &>/dev/null
done

# Install Source Code Pro Font
brew tap homebrew/cask-fonts
brew cask install font-source-code-pro

