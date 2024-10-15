#!/usr/bin/env zsh
############################
# This script creates symlinks from the home directory to any desired dotfiles in $HOME/dotfiles
# And also installs MacOS Software
# And also installs Homebrew Packages and Casks (Apps)
# And also sets up VS Code
# And also sets up Sublime Text
############################

# dotfiles directory
dotfiledir="${HOME}/dotfiles"

# Create the backup directory if it doesn't exist
currentdate=$(date +%Y-%m-%d)
backupdir="${HOME}/dotfiles/backups/${currentdate}"

mkdir -p "${backupdir}"
echo "Backup dir created"

# list of files/folders to symlink in ${homedir}
files=(zshrc zprofile zprompt bashrc bash_profile bash_prompt aliases private)

# change to the dotfiles directory
echo "Changing to the ${dotfiledir} directory"
cd "${dotfiledir}" || exit

# create symlinks (will overwrite old dotfiles)
for file in "${files[@]}"; do
    if [ -e "${HOME}/.${file}" ]; then
        # Backup existing files to the backup directory
        echo "Backing up $file to ${backupdir}"
        cp "${HOME}/.${file}" "${backupdir}/"
    fi
    
    echo "Creating symlink to $file in home directory."
    ln -sf "${dotfiledir}/.${file}" "${HOME}/.${file}"
done

# Run the MacOS Script
./macOS.sh

# Run the Homebrew Script
./brew.sh

# Run VS Code Script
./vscode.sh

# Run the Sublime Script
./sublime.sh

echo "Installation Complete!"
