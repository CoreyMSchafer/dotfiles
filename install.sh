#!/usr/bin/env zsh
############################
# This script creates symlinks from the home directory to any desired dotfiles in $HOME/dotfiles
# And also installs MacOS Software
# And also installs Homebrew Packages and Casks (Apps)
# And also sets up VS Code
############################

# dotfiles directory
dotfiledir="${HOME}/dotfiles"

# list of files/folders to symlink in ${homedir}
files=(zshrc zprofile zprompt bashrc bash_profile bash_prompt aliases private)

# change to the dotfiles directory
echo "Changing to the ${dotfiledir} directory"
cd "${dotfiledir}" || exit

# create symlinks (will overwrite old dotfiles)
for file in "${files[@]}"; do
    echo "Creating symlink to $file in home directory."
    ln -sf "${dotfiledir}/.${file}" "${HOME}/.${file}"
done

# create symlinks for configs (will overwrite old configs)
mkdir -p "${HOME}/.config/ruff"
ln -sf "${dotfiledir}/settings/ruff.toml" "${HOME}/.config/ruff/ruff.toml"

# Claude Code config: hook scripts are shared (referenced by absolute path), but
# ~/.claude/settings.json stays machine-local so personal/safety toggles aren't
# published here. Seed settings only if it doesn't already exist.
chmod +x "${dotfiledir}/claude/hooks/"*.sh
mkdir -p "${HOME}/.claude"
if [[ ! -f "${HOME}/.claude/settings.json" ]]; then
    cp "${dotfiledir}/claude/settings.example.json" "${HOME}/.claude/settings.json"
    echo "Seeded ~/.claude/settings.json from claude/settings.example.json."
else
    echo "~/.claude/settings.json exists — leaving it; merge claude/settings.example.json by hand for the hooks."
fi

# Run the MacOS Script
./macOS.sh

# Run the Homebrew Script
./brew.sh

# Run VS Code Script
./vscode.sh

echo "Installation Complete!"
