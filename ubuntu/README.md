# Ubuntu

For WSL2 on Windows or any Ubuntu machine. Links the same dotfiles as the Mac,
installs the tools in `apt.txt` plus uv, Node (from NodeSource), and the global
npm/uv tools, and makes zsh the login shell. No apps, fonts, or AI agent skills — those belong to
the host OS.

## Installation

```sh
git clone https://github.com/CoreyMSchafer/dotfiles.git ~/dotfiles && ~/dotfiles/ubuntu/install.sh
```

Log out and back in afterwards so zsh becomes the shell.
`DOTFILES_NO_INPUT=1` skips the GitHub login and the git identity prompts (handy on a test machine). apt still needs `sudo`, so an unattended run needs passwordless sudo or a fresh `sudo -v`.
The script is safe to re-run — steps that are already done are skipped.

## Files

- `install.sh`: The installer (bash, since zsh isn't installed yet when it runs; it shares `../helpers.sh` with the Mac scripts)
- `apt.txt`: The apt packages to install, one per line
