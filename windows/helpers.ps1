# Shared helpers, dot-sourced by install.ps1 (not run directly).
# The PowerShell twin of ../helpers.sh.
# These scripts run under Windows PowerShell 5.1 on a fresh machine, which reads .ps1 files
# as Windows-1252 unless they carry a BOM - so they stay plain ASCII (no em dashes, arrows).

# One timestamped backup folder per run, created only if needed
$script:BackupDir = Join-Path $HOME ".dotfiles_backup\$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss')"

function Write-Info([string]$msg)  { Write-Host '[info] ' -ForegroundColor Blue -NoNewline; Write-Host $msg }
function Write-Warn([string]$msg)  { Write-Host '[warn] ' -ForegroundColor Yellow -NoNewline; Write-Host $msg }
function Write-Err([string]$msg)   { Write-Host '[error] ' -ForegroundColor Red -NoNewline; Write-Host $msg }

# Prompt for a manual step, then wait for Enter
function Pause-For([string]$msg) {
    Write-Host ''
    Write-Host $msg
    Read-Host 'Press enter to continue...' | Out-Null
}

# Read a manifest file's entries, skipping comments and blank lines
function Read-Manifest([string]$path) {
    Get-Content $path | Where-Object { $_ -notmatch '^\s*#' -and $_ -notmatch '^\s*$' } | ForEach-Object { $_.Trim() }
}

# Link-WithBackup <source> <target>: symlink, backing up any real file already
# at <target>. Skips links that already point at <source>.
function Link-WithBackup([string]$src, [string]$dst) {
    if (-not (Test-Path $src)) { Write-Warn "Skipping link for ${dst}: source ${src} does not exist."; return }
    $existing = Get-Item -LiteralPath $dst -ErrorAction SilentlyContinue
    # .Target works in Windows PowerShell 5.1 and 7 (.LinkTarget is 7-only); 5.1 returns an array
    $target = if ($existing) { @($existing.Target)[0] -replace '^\\\\\?\\', '' }
    if ($existing -and $existing.LinkType -eq 'SymbolicLink' -and $target -and
        [IO.Path]::GetFullPath($target) -eq [IO.Path]::GetFullPath($src)) {
        Write-Info "$dst is already linked. Skipping."; return
    }
    if ($existing -and $existing.LinkType -ne 'SymbolicLink') {
        New-Item -ItemType Directory -Force $script:BackupDir | Out-Null
        Move-Item $dst (Join-Path $script:BackupDir $existing.Name)
        Write-Info "Backed up existing $($existing.Name) to $script:BackupDir\"
    } elseif ($existing) {
        Remove-Item $dst -Force   # a stale link pointing elsewhere
    }
    New-Item -ItemType Directory -Force (Split-Path $dst) | Out-Null
    New-Item -ItemType SymbolicLink -Path $dst -Target $src | Out-Null
    Write-Info "Linked $dst -> $src"
}

# Run a native command and return everything it printed as one string. Under Windows
# PowerShell 5.1 with $ErrorActionPreference = 'Stop', redirecting a native command's stderr
# turns any stderr line into a terminating error; this keeps probes like `gh auth status`
# and `sudo config` from killing the script. $LASTEXITCODE is left set by the command.
function Get-CommandOutput([scriptblock]$command) {
    $ErrorActionPreference = 'Continue'
    # stderr lines arrive as error records; keep only their text (the record's own rendering
    # includes the calling source line, which would make -match tests match this script)
    (& $command 2>&1 | ForEach-Object { if ($_ -is [Management.Automation.ErrorRecord]) { $_.Exception.Message } else { $_ } } | Out-String)
}

# Re-read PATH from the registry so tools winget just installed are callable
# in this same session (installers update the registry, not running shells)
function Update-Path {
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
}
