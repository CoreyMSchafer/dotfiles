# PowerShell 7 profile, linked to $PROFILE by windows/install.ps1.
# The native-Windows twin of .zshrc + .zprompt + .aliases: same prompt, same
# aliases where the tools exist, Windows syntax.

# --- Colors (same hex values as .shared_prompt; Windows Terminal is truecolor)
$e = [char]27
function color([string]$hex) { "$e[38;2;$([Convert]::ToInt32($hex.Substring(0,2),16));$([Convert]::ToInt32($hex.Substring(2,2),16));$([Convert]::ToInt32($hex.Substring(4,2),16))m" }
$bold = "$e[1m"; $reset = "$e[0m"
$blue = color 'afd7ff'; $steel_blue = color '5f87af'; $green = color '5faf5f'
$magenta = color 'b48ead'; $orange = color 'e47030'; $red = color 'd75f5f'
$white = color 'f1f1f1'; $yellow = color 'ffff87'

# Red username when elevated (the root equivalent)
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$userStyle = if ($isAdmin) { $red } else { $orange }
# Magenta hostname over SSH (distinct from the red admin warning)
$hostStyle = if ($env:SSH_CONNECTION) { "$bold$magenta" } else { $yellow }

# Git segment: branch name plus change markers (+ staged, ! unstaged, ? untracked, $ stashed)
function prompt_git {
    $lines = git status --porcelain --branch 2>$null
    if (-not $lines) { return '' }
    $branch = ''; $staged = ''; $unstaged = ''; $untracked = ''
    foreach ($line in $lines) {
        if ($line -like '## No commits yet on *') { $branch = $line.Substring(21) }
        elseif ($line -like '## HEAD (no branch)*') { $branch = git rev-parse --short HEAD }
        elseif ($line -like '## *') { $branch = ($line.Substring(3) -split '\.\.\.')[0] }
        elseif ($line -like '??*') { $untracked = '?' }
        else {
            if ($line[0] -ne ' ') { $staged = '+' }
            if ($line[1] -ne ' ') { $unstaged = '!' }
        }
    }
    $status = "$staged$unstaged$untracked"
    if (git rev-parse --verify refs/stash 2>$null) { $status += '$' }
    if ($status) { $status = " [$status]" }
    "$white on $blue$branch$status"
}

$env:VIRTUAL_ENV_DISABLE_PROMPT = 1
function prompt_venv {
    if ($env:VIRTUAL_ENV) { "`n$steel_blue(" + (Split-Path $env:VIRTUAL_ENV -Leaf) + ")`n" } else { '' }
}

# user at host in dir [git], then the › marker on its own line. Blank line
# before every prompt except the first (like the zsh precmd hook).
function prompt {
    $blank = if ($script:promptSeen) { "`n" } else { '' }
    $script:promptSeen = $true
    $dir = if ((Get-Location).Path -eq $HOME) { '~' } else { Split-Path -Leaf (Get-Location) }
    $user = $env:USERNAME
    $computer = $env:COMPUTERNAME.ToLower()
    "$blank$(prompt_venv)$bold$userStyle$user$white at $hostStyle$computer$white in $green$dir$(prompt_git)`n$white› $reset"
}

# --- Shell behavior (interactive sessions only; scripted `pwsh -File` runs
# and SSH commands skip the console-only bits, which would otherwise hang)
$interactive = -not [Console]::IsInputRedirected -and -not [Console]::IsOutputRedirected
if ($interactive) {
    # No inline predictions (matches the plain zsh setup); Ctrl+R history search via fzf below
    Set-PSReadLineOption -PredictionSource None
    Set-PSReadLineOption -BellStyle None
}

# --- Aliases (PowerShell's built-in ls/cat aliases are replaced with functions)
# (eza on Windows needs an explicit path — bare `eza` lists nothing — so a
# call with no arguments gets `.`)
if (Get-Command eza -ErrorAction SilentlyContinue) {
    Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue
    function ls { if ($args) { eza @args } else { eza . } }
    function la { if ($args) { eza -lahF --git @args } else { eza -lahF --git . } }
    function tree { if ($args) { eza --tree @args } else { eza --tree . } }
}
if (Get-Command bat -ErrorAction SilentlyContinue) {
    Remove-Item Alias:cat -Force -ErrorAction SilentlyContinue
    function cat { bat -p --paging=never @args }
}
# File-type colors for eza (same as .aliases): bold yellow dirs, blue symlinks, green executables
$env:LS_COLORS = 'di=01;33:ln=34:so=32:pi=33:ex=32:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'
$env:EZA_COLORS = 'ur=37:uw=37:ux=32:ue=32:gr=37:gw=37:gx=32:tr=37:tw=37:tx=32:su=31:sf=31:xa=37:sn=0:sb=37:uu=37:un=37:uR=31:gu=37:gn=37:gR=31:hd=4;37:lc=37:lm=37'

# which <name>: a program's path, or what the name is if it isn't a program (alias/function/cmdlet)
function which {
    foreach ($name in $args) {
        $found = Get-Command $name -ErrorAction SilentlyContinue
        if (-not $found) { Write-Host "$name not found"; continue }
        foreach ($cmd in $found) {
            switch ($cmd.CommandType) {
                'Application' { $cmd.Source }
                'Alias'       { "$name is an alias for $($cmd.Definition)" }
                default       { "$name is a $($cmd.CommandType.ToString().ToLower())" }
            }
        }
    }
}

# History search (ch = git commits, hg = anything)
function ch { Get-Content (Get-PSReadLineOption).HistorySavePath | Select-String 'git commit' }
function hg { Get-Content (Get-PSReadLineOption).HistorySavePath | Select-String @args }

# Copy to clipboard without newlines; pipe into it or give it a command
function c {
    if ($args.Count -eq 0) { ($input -join '') -replace "`r?`n", '' | Set-Clipboard }
    else { (& $args[0] $args[1..($args.Count)] | Out-String) -replace "`r?`n", '' | Set-Clipboard }
}

# Update everything: winget packages, npm/uv tools, skills
function update_all {
    winget upgrade --all --accept-source-agreements --accept-package-agreements
    npm update --global
    uv tool upgrade --all
    npx skills update -g -y
}

# --- Tool integrations
$env:FZF_DEFAULT_OPTS = '--color=16'
if ($interactive -and (Get-Module -ListAvailable PSFzf)) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}
