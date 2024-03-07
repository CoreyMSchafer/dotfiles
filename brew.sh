
#!/usr/bin/env zsh
set -e

# Install and configure Homebrew first
echo "Checking and installing Homebrew..."
if ! command -v brew &>/dev/null; then
    echo "Homebrew not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH in .zshrc for future terminal sessions
    echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
    export PATH="/opt/homebrew/bin:$PATH"
else
    echo "Homebrew is already installed."
fi

# Verify brew is accessible
if ! command -v brew &>/dev/null; then
    echo "Failed to configure Homebrew in PATH. Please add Homebrew to your PATH manually."
    exit 1
else
    echo "Homebrew is configured correctly."
fi

# Install iTerm2 using Homebrew
echo "Checking and installing iTerm2..."
if ! command -v iTerm &>/dev/null; then
    echo "iTerm2 not installed. Installing iTerm2..."
    brew install --cask iterm2
else
    echo "iTerm2 is already installed."
fi

# Define an array of applications to install using Homebrew Cask
apps=(
    "visual-studio-code"
    "google-chrome"
    "spotify"
    "vlc"
    "docker"
    "slack"
    "firefox"
    "zoom"
    "microsoft-teams"
    "postman"
)

# Install applications using Homebrew Cask
for app in "${apps[@]}"; do
    if brew list --cask | grep -q "^$app\$"; then
        echo "$app is already installed. Skipping..."
    else
        echo "Installing $app..."
        brew install --cask "$app"
    fi
done

# Install Miniconda
echo "Installing Miniconda..."
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh -O miniconda.sh
bash miniconda.sh -b -p $HOME/miniconda
export PATH="$HOME/miniconda/bin:$PATH"
conda init zsh
source ~/.zshrc

# Install packages within Miniconda environment
echo "Installing Python packages with Conda..."
conda install -y jupyter pandas numpy matplotlib scikit-learn

# Install Source Code Pro Font
# Tap the Homebrew font cask repository if not already tapped
brew tap | grep -q "^homebrew/cask-fonts$" || brew tap homebrew/cask-fonts

# Define the font name
font_name="font-source-code-pro"

# Check if the font is already installed
if brew list --cask | grep -q "^$font_name\$"; then
    echo "$font_name is already installed. Skipping..."
else
    echo "Installing $font_name..."
    brew install --cask "$font_name"
fi

# Once font is installed, prompt user to import Terminal settings
echo "Import your terminal settings..."
echo "Terminal -> Settings -> Profiles -> Import..."
echo "Import from ${HOME}/dotfiles/settings/Pro.terminal"
echo "Press enter to continue..."
read

# Update and clean up Homebrew installations
brew update
brew upgrade
brew upgrade --cask
brew cleanup

# Prompt user for manual actions
echo "Sign in to Google Chrome. Press enter to continue..."
read

echo "Sign in to Spotify. Press enter to continue..."
read

echo "Sign in to Discord. Press enter to continue..."
read

echo "Open Rectangle and give it necessary permissions. Press enter to continue..."
read

echo "Import your Rectangle settings located in ~/dotfiles/settings/RectangleConfig.json. Press enter to continue..."
read
