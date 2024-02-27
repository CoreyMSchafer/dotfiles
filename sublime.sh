#!/usr/bin/env zsh

# Check if Homebrew's bin exists and if it's not already in the PATH
if [ -x "/opt/homebrew/bin/brew" ] && [[ ":$PATH:" != *":/opt/homebrew/bin:"* ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
fi

# Check if 'subl' command is available
if ! command -v subl &>/dev/null; then
    echo "'subl' command not found. Creating symlink for Sublime Text."

    # Creating the symlink for Sublime Text's 'subl' command-line tool
    # Ensure Sublime Text is installed in the Applications folder
    if [ -e "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" ]; then
        # Create the symlink in /usr/local/bin
        ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/local/bin/subl
        echo "Symlink created successfully."
    else
        echo "Sublime Text application not found in the expected location. Please ensure it's installed in the Applications folder."
    fi
else
    echo "'subl' command is already available."
fi

# Open Sublime Text to create necessary folders
subl .

CONFIG_PATH="$HOME/Library/Application Support/Sublime Text/Installed Packages"
MAX_WAIT=30 # Maximum number of seconds to wait
waited=0

until [[ -d "$CONFIG_PATH" ]] || [[ $waited -ge $MAX_WAIT ]]; do
    echo "Waiting for Sublime Text to initialize..."
    sleep 1
    ((waited++))
done

if [[ -d "$CONFIG_PATH" ]]; then
    echo "Sublime Text initialized."
else
    echo "Sublime Text did not initialize within $MAX_WAIT seconds."
    exit 1
fi

# Quit Sublime after folder are created
osascript -e 'quit app "Sublime Text"'

# Install Latest version of Package Control
curl -L -o "$HOME/Library/Application Support/Sublime Text/Installed Packages/Package Control.sublime-package" "https://github.com/wbond/package_control/releases/latest/download/Package.Control.sublime-package"

# Define paths for clarity and reusability
USER_PACKAGES_DIR="$HOME/Library/Application Support/Sublime Text/Packages/User"

# Copy packages that should be installed
cp "settings/Package Control.sublime-settings" "$HOME/Library/Application Support/Sublime Text/Packages/User/Package Control.sublime-settings"

# Open Sublime Text to install packages
echo "Opening Sublime to automatically install packages"
subl .
echo "Press Enter after Packages are all installed..."
read

# Quit Sublime after packages are installed
osascript -e 'quit app "Sublime Text"'

# Copy custom settings, keymaps, and other configurations
cp "settings/Preferences.sublime-settings" "$USER_PACKAGES_DIR/Preferences.sublime-settings"
cp "settings/Default (OSX).sublime-keymap" "$USER_PACKAGES_DIR/Default (OSX).sublime-keymap"
cp "settings/Material-Theme-Darker.sublime-theme" "$USER_PACKAGES_DIR/Material-Theme-Darker.sublime-theme"
cp "settings/JsPrettier.sublime-settings" "$USER_PACKAGES_DIR/JsPrettier.sublime-settings"
cp "settings/SublimeLinter.sublime-settings" "$USER_PACKAGES_DIR/SublimeLinter.sublime-settings"

# Copy custom build systems
cp "settings/Python-3.sublime-build" "$USER_PACKAGES_DIR/Python-3.sublime-build"

# I had issues with using the $HOME variable in a Sublime build system
# So I just create this file manually in the shell and push it with the home directory hard coded
echo "{
  \"cmd\": [\"$HOME/tutorial/bin/python\", \"-u\", \"\$file\"],
  \"file_regex\": \"^[ ]*File \\\"(...*?)\\\", line ([0-9]*)\",
  \"quiet\": true
}" >"$USER_PACKAGES_DIR/Python-Tut-Env.sublime-build"

echo "Custom Sublime Text settings and packages have been copied."

# Open Sublime Text to check for errors and to enter your license key
subl .
echo "You can view potential Sublime Text errors by pressing Ctrl + backtick"
echo "If there are no errors, activate your Sublime license."
echo "Press enter to continue..."
read
