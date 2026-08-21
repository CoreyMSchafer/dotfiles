# Development Environment Setup

This repository contains scripts and configuration files to set up a development environment for macOS. It's tailored for software development, focusing on a clean, minimal, and efficient setup.

## YouTube Video Walkthrough

Click on the image below to watch the video on YouTube:

[![Watch the video](https://img.youtube.com/vi/ra5kMCXO-6I/0.jpg)](https://youtu.be/ra5kMCXO-6I)

## Overview

The setup includes automated scripts for installing essential software, configuring Bash and Zsh shells, and setting up Visual Studio Code. This guide will help you replicate my development environment on your machine if you desire to do so.

## Important Note Before Installation

**WARNING:** The configurations and scripts in this repository are **HIGHLY PERSONALIZED** to my own preferences and workflows. If you decide to use them, please be aware that they will **MODIFY** your current system, potentially making some changes that are **IRREVERSIBLE** without a fresh installation of your operating system.

The scripts are safe to re-run: each step checks the current state before changing anything, and any existing file that would be replaced by a symlink (e.g. an existing `.zshrc` or VS Code `settings.json`) is first moved into a timestamped folder under `~/.dotfiles_backup/`, so earlier backups are never overwritten. That said, not everything can be backed up — system settings changed via `defaults write` and installed/upgraded software have no backup mechanism — so the warning above still stands.

If you would like a development environment similar to mine, I highly encourage you to fork this repository and make your own personalized changes to these scripts instead of running them exactly as I have them written for myself.

A less serious (but potentially annoying) change it will make is setting the Desktop background to the image I use in my tutorials. This is the script I use to set up machines I will be recording on, after all.

I likely won't accept pull requests unless they align closely with my personal preferences and the way I use my development environment. But if there are some obvious errors in my scripts then corrections would be welcome!

If you choose to run these scripts, please do so with **EXTREME CAUTION**. It's recommended to review the scripts and understand the changes they will make to your system before proceeding.

By using these scripts, you acknowledge and accept the risk of potential data loss or system alteration. Proceed at your own risk.

## Getting Started

### Prerequisites

-  macOS (The scripts are tailored for macOS)

### Installation

> **Note:** On a brand-new Mac, the first `git clone` will pop up a dialog
> asking to install the Xcode Command Line Tools (macOS ships a `git` stub
> that requests them). Click Install, wait for it to finish, then re-run the
> clone command. This is expected — the real install can't begin until the
> tools that download it exist.

1. Clone the repository to your local machine:
   ```sh
   git clone https://github.com/CoreyMSchafer/dotfiles.git ~/dotfiles
   ```
2. Navigate to the `dotfiles` directory:
   ```sh
   cd ~/dotfiles
   ```
3. Run the installation script:
   ```sh
   ./install.sh
   ```

This script will:

-  Create symlinks for dotfiles (`.bashrc`, `.zshrc`, etc.), backing up any existing files to `~/.dotfiles_backup/`
-  Run macOS-specific configurations (`macOS.sh`)
-  Install Homebrew, then the packages, apps, and fonts listed in the `Brewfile` (`brew.sh`)
-  Configure Visual Studio Code and install the extensions listed in `vscode-extensions.txt` (`vscode.sh`)

The script is safe to re-run — steps that are already done are skipped.

## Configuration Files

-  `.bashrc` & `.zshrc`: Shell configuration files for Bash and Zsh.
-  `.shared_prompt`: Custom prompt setup used by both `.bash_prompt` & `.zprompt`
-  `.bash_prompt` & `.zprompt`: Custom prompt setup for Bash and Zsh.
-  `.bash_profile`: Setting system-wide environment variables
-  `.aliases`: Aliases for common commands. Some are personalized to my machines specifically (e.g. the 'yt' alias opening my YouTube Scripts')
-  `.private`: Machine-local file for private information; created empty by `install.sh` and never uploaded to version control
-  `Brewfile`: The list of Homebrew packages, apps, and fonts that `brew.sh` installs via `brew bundle`
-  `vscode-extensions.txt`: The list of VS Code extensions that `vscode.sh` installs
-  `helpers.sh`: Small helpers (logging, backup-then-symlink) shared by the install scripts
-  `settings/`: Directory containing editor settings and configurations for Visual Studio Code.

### Customizing Your Setup

You're encouraged to modify the scripts and configuration files to suit your preferences. Here are some tips for customization:

-  **Dotfiles**: Edit `.shared_prompt`, `.zprompt`, `.bash_prompt` to add or modify shell configurations.
-  **VS Code**: Adjust settings in the `settings/` directory to change editor preferences and themes.

## Contributing

Feel free to fork this repository and customize it for your setup. Pull requests for improvements and bug fixes are welcome, but as said above, I likely won't accept pull requests that simply add additional brew installations or change some settings unless they align with my personal preferences.

## License

This project is licensed under the MIT License - see the [LICENSE-MIT.txt](LICENSE-MIT.txt) file for details.

## Acknowledgments

-  I originally forked this from [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles)
-  Thanks to all the open-source projects used in this setup.
