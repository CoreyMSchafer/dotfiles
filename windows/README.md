# Windows

The native Windows layer: winget packages, a PowerShell 7 profile with the same
prompt and aliases as the Mac, the color scheme and font for Windows Terminal,
and the shared configs (bat, ruff, ssh, VS Code). It also enables WSL2 with
Ubuntu, where the [`ubuntu/`](../ubuntu/) installer gives the shell setup.

## Installation

1. Clone the repository to `$HOME\dotfiles` (Git for Windows, or `winget install Git.Git` first;
   PowerShell doesn't expand `~` for git, so use `$HOME`):
   ```powershell
   git clone https://github.com/CoreyMSchafer/dotfiles.git $HOME\dotfiles
   ```
2. Run the script from an elevated PowerShell (Windows Terminal → Run as administrator):
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process
   & $HOME\dotfiles\windows\install.ps1
   ```
   It installs everything in `winget.txt`, links the PowerShell profile, applies
   the color scheme and font to Windows Terminal, links the bat/ruff/ssh/VS Code
   configs, installs the fonts in `../fonts.txt`, and enables WSL with Ubuntu. It
   asks for a reboot at the end.
3. After the reboot, open Ubuntu from the Start menu, create your Linux user, then:
   ```sh
   git clone https://github.com/CoreyMSchafer/dotfiles.git ~/dotfiles && ~/dotfiles/ubuntu/install.sh
   ```

`-NoInput` skips every prompt: computer name, git identity, the GitHub login, and the sign-in pauses (handy on a test machine).
The script is safe to re-run — steps that are already done are skipped.

## SSH into this PC

Windows ships the OpenSSH server as an optional feature. From an elevated PowerShell:

```powershell
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Set-Service sshd -StartupType Automatic; Start-Service sshd
Set-NetConnectionProfile -NetworkCategory Private   # the firewall rule only applies to Private networks
New-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShell -Value 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -PropertyType String -Force
Restart-Service sshd
```

The last two lines make SSH sessions land in Windows PowerShell 5.1 instead of cmd, with
the same profile and prompt as PowerShell 7. (winget installs the Store build of
PowerShell 7, which Microsoft documents as unsupported for inbound remoting: it can't be
started from an SSH session at all. `wsl` works from there as usual.)

Administrator accounts read keys from `C:\ProgramData\ssh\administrators_authorized_keys`
(not `~\.ssh\authorized_keys`), and sshd refuses the file unless only Administrators and
SYSTEM can access it:

```powershell
Set-Content C:\ProgramData\ssh\administrators_authorized_keys 'ssh-ed25519 AAAA... you@host' -Encoding ascii
icacls C:\ProgramData\ssh\administrators_authorized_keys /inheritance:r /grant Administrators:F /grant SYSTEM:F
```

Then `ssh <user>@<computer-name>` from another machine, and `wsl ~` once in for the Ubuntu side.

## Files

-  `install.ps1`: The installer
-  `helpers.ps1`: Logging, backup-then-symlink, and manifest helpers (the PowerShell twin of `../helpers.sh`)
-  `settings.ps1`: Windows preferences (the `macOS.sh` counterpart) — screenshot folder, hidden files and extensions in Explorer, no Snap Assist popup, Edge kept quiet (no search bar or preloading), Game Bar recording off, a few preinstalled apps removed (Phone Link, Widgets, Bing, Xbox, OneDrive), long paths, `sudo`, PowerToys Keyboard Manager remaps, desktop background
-  `fonts.ps1`: Per-user font install from `../fonts.txt` (Google Fonts and Font Awesome)
-  `winget.txt`: The winget packages to install, one ID per line
-  `settings/`: The PowerShell profile, and the Windows Terminal color scheme and defaults that `install.ps1` merges into its settings
