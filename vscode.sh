#!/usr/bin/env zsh

# Check if Homebrew's bin exists and if it's not already in the PATH
if [ -x "/opt/homebrew/bin/brew" ] && [[ ":$PATH:" != *":/opt/homebrew/bin:"* ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
fi

# Install VS Code Extensions
extensions=(
    batisteo.vscode-django
    charliermarsh.ruff
    esbenp.prettier-vscode
    formulahendry.code-runner
    foxundermoon.shell-format
    github.copilot
    github.copilot-chat
    mechatroner.rainbow-csv
    monosans.djlint
    ms-python.mypy-type-checker
    ms-python.python
    ms-toolsai.jupyter
    ms-vscode.theme-predawnkit
    mtxr.sqltools
    mtxr.sqltools-driver-sqlite
    ritwickdey.liveServer
    tamasfe.even-better-toml
    teabyii.ayu
    tomoki1207.pdf
)

# Get a list of all currently installed extensions.
installed_extensions=$(code --list-extensions)

for extension in "${extensions[@]}"; do
    if echo "$installed_extensions" | grep -qi "^$extension$"; then
        echo "$extension is already installed. Skipping..."
    else
        echo "Installing $extension..."
        code --install-extension "$extension"
    fi
done

echo "VS Code extensions have been installed."

# Define the target directory for VS Code user settings on macOS
VSCODE_USER_SETTINGS_DIR="${HOME}/Library/Application Support/Code/User"

# Check if VS Code settings directory exists
if [ -d "$VSCODE_USER_SETTINGS_DIR" ]; then
    # Copy your custom settings.json and keybindings.json to the VS Code settings directory
    ln -sf "${HOME}/dotfiles/settings/VSCode-Settings.json" "${VSCODE_USER_SETTINGS_DIR}/settings.json"
    ln -sf "${HOME}/dotfiles/settings/VSCode-Keybindings.json" "${VSCODE_USER_SETTINGS_DIR}/keybindings.json"

    echo "VS Code settings and keybindings have been updated."
else
    echo "VS Code user settings directory does not exist. Please ensure VS Code is installed."
fi

# Open VS Code to sign-in to extensions
code .
echo "Login to extensions (Copilot, Grammarly, etc) within VS Code."
echo "Press enter to continue..."
read
