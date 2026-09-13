# Windows

The native Windows layer: winget packages, a PowerShell 7 profile with the same
prompt and aliases as the Mac, the color scheme and font for Windows Terminal,
and the shared configs (bat, ruff, ssh, VS Code). It also enables WSL2 with
Ubuntu, where the [`ubuntu/`](../ubuntu/) installer gives the shell setup.

## Installation

1. Clone the repository to `~\dotfiles` (Git for Windows, or `winget install Git.Git` first):
   ```powershell
   git clone https://github.com/CoreyMSchafer/dotfiles.git ~\dotfiles
   ```
2. Run the script from an elevated PowerShell (Windows Terminal → Run as administrator):
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process
   ~\dotfiles\windows\install.ps1
   ```
   It installs everything in `winget.txt`, links the PowerShell profile, applies
   the color scheme and font to Windows Terminal, links the bat/ruff/ssh/VS Code
   configs, installs the fonts in `../fonts.txt`, and enables WSL with Ubuntu. It
   asks for a reboot at the end.
3. After the reboot, open Ubuntu from the Start menu, create your Linux user, then:
   ```sh
   git clone https://github.com/CoreyMSchafer/dotfiles.git ~/dotfiles && ~/dotfiles/ubuntu/install.sh
   ```

`-SkipSignIn` skips the GitHub login and the sign-in pauses (handy on a test machine).
The script is safe to re-run — steps that are already done are skipped.

## Files

-  `install.ps1`: The installer
-  `helpers.ps1`: Logging, backup-then-symlink, and manifest helpers (the PowerShell twin of `../helpers.sh`)
-  `settings.ps1`: Windows preferences (the `macOS.sh` counterpart) — screenshot folder, hidden files and extensions in Explorer, long paths, `sudo`, PowerToys modules
-  `fonts.ps1`: Per-user font install from `../fonts.txt` (Google Fonts and Font Awesome)
-  `winget.txt`: The winget packages to install, one ID per line
-  `settings/`: The PowerShell profile, and the Windows Terminal color scheme and defaults that `install.ps1` merges into its settings
