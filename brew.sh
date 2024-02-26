#!/usr/bin/env zsh

# Check if Homebrew is installed
if ! command -v brew &>/dev/null; then
    echo "Homebrew not installed. Installing Homebrew."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi

# Update Homebrew and Upgrade any already-installed formulae
brew update
brew upgrade
brew upgrade --cask
brew cleanup

# Define an array of packages to install using Homebrew.
packages=(
    "python"
    "bash"
    "zsh"
    "git"
    "tree"
    "pylint"
    "black"
    "node"
)

# Loop over the array to install each application.
for package in "${packages[@]}"; do
    brew install "$package"
done

# Add the Homebrew zsh to allowed shells
echo "$(brew --prefix)/bin/zsh" | sudo tee -a /etc/shells >/dev/null
# Set the Homebrew zsh as default shell
chsh -s "$(brew --prefix)/bin/zsh"

# Git config name
read -p "Please enter your name for Git configuration: " git_user_name

# Git config email
read -p "Please enter your email for Git configuration: " git_user_email

# Set my git credentials
$(brew --prefix)/bin/git config --global user.name "$git_user_name"
$(brew --prefix)/bin/git config --global user.email "$git_user_email"

# Create the tutorial virtual environment I use frequently
$(brew --prefix)/bin/python3 -m venv "${HOME}/tutorial"

# Install Prettier, which I use in both VS Code and Sublime Text
$(brew --prefix)/bin/npm install --global prettier

# Install Source Code Pro Font
brew tap homebrew/cask-fonts
brew install --cask font-source-code-pro

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

# Update and clean up again for safe measure
brew update
brew upgrade
brew upgrade --cask
brew cleanup

read -p "Sign in to Google Chrome. Press enter to continue..."
read -p "Sign in to Spotify. Press enter to continue..."
read -p "Sign in to Discord. Press enter to continue..."
read -p "Open Rectangle and give it necessary permissions. Press enter to continue..."
read -p "Import your Rectangle settings located in ~/dotfiles/settings/RectangleConfig.json. Press enter to continue..."
