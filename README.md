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

-  macOS (see [Other systems](#other-systems) for Windows and Ubuntu)

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

-  Create symlinks for dotfiles (`.zshrc`, `.aliases`, etc.), backing up any existing files to `~/.dotfiles_backup/`
-  Run macOS-specific configurations (`macOS.sh`)
-  Install Homebrew, then everything listed in `packages.txt`, `apps.txt`, and `fonts.txt` (`brew.sh`)
-  Configure Visual Studio Code and install the extensions listed in `vscode-extensions.txt` (`vscode.sh`)

The script is safe to re-run — steps that are already done are skipped.
`./install.sh --no-input` skips every prompt: computer name, git identity, the GitHub login, and the sign-in pauses (handy on a test machine).

### Other systems

I occasionally need this setup on other machines. Those installs live in their own folders, each with its own README:

-  Windows 11: [`windows/`](windows/) (winget, PowerShell 7, Windows Terminal)
-  Ubuntu, including WSL2 on Windows: [`ubuntu/`](ubuntu/)

## Configuration Files

-  `.zshrc`: Shell configuration for Zsh (the only shell these dotfiles target).
-  `.zprompt`: The prompt — user, host, directory, and Git branch/status.
-  `.aliases`: Aliases for common commands (`ls`/`la`/`tree` run `eza`, `cat` runs `bat`, with plain fallbacks when those aren't installed).
-  `.private`: Machine-local file for private information; created empty by `install.sh` and never uploaded to version control
-  `~/.config/zsh/*.zsh`: Not in this repo — a drop-in folder that `.zshrc` sources last, for anything machine-local or not meant for every fork (my private work repo links its shell helpers there)
-  `packages.txt`, `apps.txt`, `fonts.txt`: The Homebrew packages, cask apps, and fonts that `brew.sh` installs
-  `fonts/`: Fonts Homebrew doesn't carry, kept in the repo (desktop formats installed on every OS, `.woff2` for web projects)
-  `helpers.sh`: Logging, backup-then-symlink, and manifest helpers shared by the macOS and Linux scripts
-  `windows/`: The Windows port — `install.ps1`, `winget.txt`, and `settings/` (PowerShell profile, Windows Terminal color scheme and defaults)
-  `ubuntu/`: The Ubuntu/WSL installer — `install.sh` and `apt.txt`
-  `vscode-extensions.txt`: The list of VS Code extensions that `vscode.sh` installs
-  `skills_ai.txt`: AI coding-agent skills (`npx skills`) that `brew.sh` and `windows/install.ps1` install globally
-  `settings/`: Config files that `install.sh` symlinks into place — Ghostty (my terminal), VS Code settings/keybindings, `~/.ssh/config`, `bat`, and `ruff`.

### Customizing Your Setup

You're encouraged to modify the scripts and configuration files to suit your preferences. Here are some tips for customization:

-  **Dotfiles**: Edit `.zshrc`, `.zprompt`, and `.aliases` to add or modify shell configurations.
-  **VS Code**: Adjust settings in the `settings/` directory to change editor preferences and themes.

## Contributing

Feel free to fork this repository and customize it for your setup. Pull requests for improvements and bug fixes are welcome, but as said above, I likely won't accept pull requests that simply add additional brew installations or change some settings unless they align with my personal preferences.

## License

This project is licensed under the MIT License - see the [LICENSE-MIT.txt](LICENSE-MIT.txt) file for details.

## Acknowledgments

-  I originally forked this from [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles)
-  Thanks to all the open-source projects used in this setup.
