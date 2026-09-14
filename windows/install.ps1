#Requires -RunAsAdministrator
############################
# Sets up a Windows machine (the native layer; WSL gets ../ubuntu/install.sh):
#   1. Installs winget packages and apps       (winget.txt)
#   2. Links config files into place           (PowerShell profile, Terminal, bat, ruff, ssh, VS Code)
#      and sets Windows preferences          (settings.ps1)
#   3. Installs global npm/uv tools, AI agent skills, VS Code extensions, fonts
#   4. Enables WSL (Ubuntu) - needs a reboot, then run ubuntu/install.sh inside it
#
# Run from an elevated PowerShell:  Set-ExecutionPolicy Bypass -Scope Process; .\windows\install.ps1
# Safe to re-run: steps check before changing anything, and replaced files
# are backed up to ~\.dotfiles_backup\<timestamp>\
############################

# -NoInput: never wait for a person (test VMs). Skips the computer-name and git identity
# prompts, the GitHub login, and the sign-in pauses.
param([switch]$NoInput)
$ErrorActionPreference = 'Stop'

# The prompts hardcode ~\dotfiles, so refuse to run from anywhere else
$dotfiledir = Split-Path -Parent $PSScriptRoot
if ((Resolve-Path $dotfiledir).Path -ne (Join-Path $HOME 'dotfiles')) {
    Write-Host "This repo must live at $HOME\dotfiles (currently running from $dotfiledir)." -ForegroundColor Red
    Write-Host "Clone it there and re-run:  git clone https://github.com/CoreyMSchafer/dotfiles.git $HOME\dotfiles"
    exit 1
}
. "$PSScriptRoot\helpers.ps1"
Set-Location $dotfiledir

# --- winget packages and apps
# Installers drop shortcuts on the Desktop; remember what was there so only the new ones are removed at the end
$desktopBefore = @(Get-ChildItem "$HOME\Desktop\*.lnk", "$env:PUBLIC\Desktop\*.lnk" -ErrorAction SilentlyContinue).FullName
$packages = Read-Manifest "$PSScriptRoot\winget.txt"
$installed = Get-CommandOutput { winget list --accept-source-agreements }
foreach ($id in $packages) {
    if ($installed -match [regex]::Escape($id)) { Write-Info "$id is already installed. Skipping."; continue }
    Write-Info "Installing $id..."
    winget install --id $id --exact --silent --accept-source-agreements --accept-package-agreements | Out-Null
    # Trust the package list, not the exit code: portable packages can extract and
    # still fail to register, and some installers (Postman) return before they finish
    if (-not ((Get-CommandOutput { winget list --id $id --exact }) -match [regex]::Escape($id))) {
        Write-Warn "$id is not registered with winget yet (its installer may still be running) - re-run the script later to check."
    }
}
Update-Path   # tools installed above become callable from here on

# --- Config files
# PowerShell 7 profile
Link-WithBackup "$PSScriptRoot\settings\Microsoft.PowerShell_profile.ps1" "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
# fzf keybindings for PowerShell (Ctrl+R history) come from the PSFzf module. It's installed
# by PowerShell 7 itself (winget put it in place above): 7's Install-PSResource needs no
# NuGet-provider bootstrap - that download hangs under Windows PowerShell 5.1 - and the
# module lands in 7's own module path, which is the PowerShell the profile runs in.
$pwsh = (Get-Command pwsh -ErrorAction SilentlyContinue).Source
if (-not $pwsh) { $pwsh = "$env:LOCALAPPDATA\Microsoft\WindowsApps\pwsh.exe" }
if (-not (Test-Path $pwsh)) {
    Write-Warn 'pwsh not found; skipping the PSFzf module (re-run after PowerShell 7 is installed).'
} elseif (& $pwsh -NoProfile -Command 'Get-Module -ListAvailable PSFzf') {
    Write-Info 'PSFzf module already installed. Skipping.'
} else {
    Write-Info 'Installing the PSFzf module...'
    & $pwsh -NoProfile -Command 'Install-PSResource PSFzf -Scope CurrentUser -TrustRepository -Quiet'
}

# Windows Terminal rewrites its settings.json, so merge into it instead of linking:
# add/replace the CMS scheme, apply the defaults, make PowerShell 7 the default profile
$wtSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (Test-Path $wtSettings) {
    $wt = Get-Content $wtSettings -Raw | ConvertFrom-Json
    $scheme = Get-Content "$PSScriptRoot\settings\cms-scheme.json" -Raw | ConvertFrom-Json
    $wt.schemes = @($wt.schemes | Where-Object { $_.name -ne $scheme.name }) + $scheme
    $defaults = Get-Content "$PSScriptRoot\settings\terminal-defaults.json" -Raw | ConvertFrom-Json
    if (-not $wt.profiles.defaults) { $wt.profiles | Add-Member -NotePropertyName defaults -NotePropertyValue ([pscustomobject]@{}) }
    foreach ($p in $defaults.PSObject.Properties) { $wt.profiles.defaults | Add-Member -NotePropertyName $p.Name -NotePropertyValue $p.Value -Force }
    # Terminal only generates its PowerShell 7 profile entry the next time it launches,
    # but that entry's GUID is deterministic, so point at it either way
    $pwsh = $wt.profiles.list | Where-Object { $_.source -eq 'Windows.Terminal.PowershellCore' } | Select-Object -First 1
    $wt.defaultProfile = if ($pwsh) { $pwsh.guid } else { '{574e775e-4f2a-5b96-ac1e-a2962a402336}' }
    $wt | ConvertTo-Json -Depth 32 | Set-Content $wtSettings -Encoding utf8
    Write-Info 'Windows Terminal: CMS scheme, defaults, and PowerShell 7 as the default profile.'
} else { Write-Warn 'Windows Terminal settings.json not found (open Terminal once, then re-run).' }

# bat config + color scheme (theme cache built below)
Link-WithBackup "$dotfiledir\settings\bat-config" "$env:APPDATA\bat\config"
Link-WithBackup "$dotfiledir\settings\bat-themes" "$env:APPDATA\bat\themes"
# Ruff global config
Link-WithBackup "$dotfiledir\settings\ruff.toml" "$env:APPDATA\ruff\ruff.toml"
# SSH client config (personal hosts go in the untracked config.local)
Link-WithBackup "$dotfiledir\settings\ssh-config" "$HOME\.ssh\config"
# VS Code settings and keybindings
Link-WithBackup "$dotfiledir\settings\VSCode-Settings.json" "$env:APPDATA\Code\User\settings.json"
Link-WithBackup "$dotfiledir\settings\VSCode-Keybindings.json" "$env:APPDATA\Code\User\keybindings.json"

# Register the Predawn bat theme
if ((Get-CommandOutput { bat --list-themes }) -match '(?m)^Predawn\s*$') { Write-Info 'bat theme cache already built. Skipping.' }
else { Write-Info "Building bat's theme cache..."; bat cache --build | Out-Null }

# --- Windows preferences (screenshot folder, ...) - what macOS.sh does on the Mac
. "$PSScriptRoot\settings.ps1"

# --- Computer name (Enter keeps the current one; a change takes effect after the reboot)
if ($NoInput) { Write-Info 'Skipping the computer-name prompt (-NoInput).' }
else {
    while ($true) {
        $newName = Read-Host "Computer name [$env:COMPUTERNAME] (Enter to keep)"
        if (-not $newName -or $newName -eq $env:COMPUTERNAME) { Write-Info "Computer name stays $env:COMPUTERNAME."; break }
        if ($newName -match '^[A-Za-z0-9-]{1,15}$') {
            Rename-Computer -NewName $newName -Force -WarningAction SilentlyContinue | Out-Null
            Write-Info "Computer name will be $newName after the reboot."
            break
        }
        Write-Warn 'Windows computer names are 1-15 letters, digits, or hyphens (longer names get truncated). Try again.'
    }
}

# --- Git config (prompt only if not already set)
if ($NoInput -and -not (git config --global --get user.name)) {
    Write-Warn "Git user.name not set (-NoInput). Set it later: git config --global user.name 'Your Name'"
} elseif (-not (git config --global --get user.name)) {
    $name = Read-Host 'Please enter your FULL NAME for Git configuration'
    git config --global user.name $name
    Write-Info "Git user.name has been set to $name"
} else { Write-Info "Git user.name is already set to '$(git config --global --get user.name)'. Skipping configuration." }
if ($NoInput -and -not (git config --global --get user.email)) {
    Write-Warn 'Git user.email not set (-NoInput). Set it later: git config --global user.email you@example.com'
} elseif (-not (git config --global --get user.email)) {
    $email = Read-Host 'Please enter your EMAIL for Git configuration'
    git config --global user.email $email
    Write-Info "Git user.email has been set to $email"
} else { Write-Info "Git user.email is already set to '$(git config --global --get user.email)'. Skipping configuration." }
git config --global init.defaultBranch main

# GitHub login (skipped if already authenticated)
if ($NoInput) { Write-Info 'Skipping GitHub login (-NoInput).' }
else {
    Get-CommandOutput { gh auth status } | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Info 'You will need to authenticate with GitHub. Follow the prompts to login...'
        gh auth login
    } else { Write-Info 'Already authenticated with GitHub. Skipping login.' }
}

# --- Global npm tools, which I use in VS Code
npm install --global prettier   # Code formatter
npm install --global eslint     # JavaScript linter

# --- Global uv tools (djlint/ruff/ty as on the Mac; pre-commit comes from Homebrew
# there but has no winget package). ocrmypdf lives on the WSL side (apt).
foreach ($tool in 'djlint', 'ruff', 'ty', 'pre-commit') { uv tool install $tool }

# --- AI agent skills (skills_ai.txt): installed globally and linked into the listed
# agents' skills folders (without -a the CLI creates a folder for every agent it knows about)
$skillAgents = @('-a', 'claude-code', '-a', 'codex')
foreach ($line in (Read-Manifest "$dotfiledir\skills_ai.txt")) {
    $repo, $skill = $line -split '\s+', 2
    npx skills add $repo -g -y -s $skill @skillAgents
}

# --- VS Code extensions (one failure shouldn't abort the rest)
$installedExt = (Get-CommandOutput { code --list-extensions }) -split "`r?`n"
foreach ($ext in (Read-Manifest "$dotfiledir\vscode-extensions.txt")) {
    if ($installedExt -contains $ext) { Write-Info "$ext is already installed. Skipping."; continue }
    Write-Info "Installing $ext..."
    code --install-extension $ext | Out-Null
    if ($LASTEXITCODE -ne 0) { Write-Warn "Failed to install $ext - continuing with the rest." }
}

# --- Fonts: the same families as fonts.txt, fetched from Google Fonts' GitHub
# repo (the source the Homebrew casks use) and installed per-user
. "$PSScriptRoot\fonts.ps1"

# --- WSL (Ubuntu). Enabling the feature needs a reboot; Ubuntu's first launch
# then asks for a username/password, after which ../ubuntu/install.sh takes over.
if ((Get-CommandOutput { wsl --status }) -match 'Default Distribution') { Write-Info 'WSL is already set up. Skipping.' }
else {
    Write-Info 'Enabling WSL and installing Ubuntu (a reboot will be required)...'
    wsl --install -d Ubuntu --no-launch
}

# --- Remove the shortcuts the installers above dropped on the Desktop (everything is in the Start menu)
$links = @(Get-ChildItem "$HOME\Desktop\*.lnk", "$env:PUBLIC\Desktop\*.lnk" -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notin $desktopBefore })
if ($links.Count -gt 0) {
    $links | Remove-Item -Force
    Write-Info "Removed $($links.Count) installer shortcut(s) from the Desktop."
}

if (-not $NoInput) {
    Pause-For 'Sign in to Google Chrome.'
    Pause-For 'Sign in to Google Drive.'
    Pause-For 'Sign in to Discord.'
    Pause-For 'Open PowerToys and set up a FancyZones layout.'
    Pause-For 'Sign in to your accounts (GitHub Copilot, etc.) within VS Code.'
}

Write-Host ''
Write-Info 'Installation Complete!'
if (Test-Path $script:BackupDir) { Write-Info "Files replaced by this run were backed up to $script:BackupDir" }
Write-Info 'Reboot to finish enabling WSL, then open Ubuntu from the Start menu and run:'
Write-Info '  git clone https://github.com/CoreyMSchafer/dotfiles.git ~/dotfiles && cd ~/dotfiles && ./ubuntu/install.sh'
