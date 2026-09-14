# Installs the fonts in ../fonts.txt for the current user (dot-sourced by install.ps1).
# Google Fonts families come from the google/fonts GitHub repo, Font Awesome from its
# release zip. Safe to re-run: installed families are skipped.

$fontDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
$fontReg = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
New-Item -ItemType Directory -Force $fontDir | Out-Null

# Copy a font file into the per-user font folder and register it (-LiteralPath: variable
# fonts are named like Caveat[wght].ttf, and PowerShell reads brackets as wildcards)
function Install-FontFile([string]$path) {
    $name = Split-Path -Leaf $path
    $dest = Join-Path $fontDir $name
    if (Test-Path -LiteralPath $dest) { return }
    Copy-Item -LiteralPath $path -Destination $dest
    $type = if ($name -like '*.otf') { 'OpenType' } else { 'TrueType' }
    New-ItemProperty -Path $fontReg -Name "$([IO.Path]::GetFileNameWithoutExtension($name)) ($type)" -Value $dest -PropertyType String -Force | Out-Null
}

# Download to an exact path (-OutFile treats brackets as wildcards under 5.1; .NET doesn't)
function Save-Url([string]$url, [string]$path) {
    [IO.File]::WriteAllBytes($path, (Invoke-WebRequest $url -UseBasicParsing).Content)
}

$tmp = Join-Path $env:TEMP 'dotfiles-fonts'
New-Item -ItemType Directory -Force $tmp | Out-Null

foreach ($entry in (Read-Manifest "$dotfiledir\fonts.txt")) {
    $family = $entry -replace '^font-', ''              # font-source-code-pro -> source-code-pro
    $dirName = $family -replace '-', ''                 # google/fonts folder: sourcecodepro
    if (Get-ChildItem $fontDir -Filter "*$($dirName)*" -ErrorAction SilentlyContinue) {
        Write-Info "$family is already installed. Skipping."; continue
    }
    Write-Info "Installing $family..."
    try {
        if ($family -eq 'fontawesome') {
            # Desktop OTFs ship in the Font Awesome Free release zip
            $rel = Invoke-RestMethod 'https://api.github.com/repos/FortAwesome/Font-Awesome/releases/latest'
            $asset = $rel.assets | Where-Object { $_.name -like 'fontawesome-free-*-desktop.zip' } | Select-Object -First 1
            $zip = Join-Path $tmp $asset.name
            Save-Url $asset.browser_download_url $zip
            Expand-Archive $zip -DestinationPath (Join-Path $tmp 'fontawesome') -Force
            Get-ChildItem (Join-Path $tmp 'fontawesome') -Recurse -Filter '*.otf' | ForEach-Object {
                Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $tmp "fontawesome-$($_.Name)")
                Install-FontFile (Join-Path $tmp "fontawesome-$($_.Name)")
            }
        } else {
            # Google Fonts: list the family's folder (ofl/, then apache/ or ufl/) and download the .ttf files
            $files = $null
            foreach ($license in 'ofl', 'apache', 'ufl') {
                try { $files = Invoke-RestMethod "https://api.github.com/repos/google/fonts/contents/$license/$dirName"; break } catch {}
            }
            if (-not $files) { throw "not found in google/fonts" }
            foreach ($f in ($files | Where-Object { $_.name -like '*.ttf' })) {
                $local = Join-Path $tmp $f.name
                Save-Url $f.download_url $local
                Install-FontFile $local
            }
        }
    } catch { Write-Warn "Could not install ${family}: $_" }
}
Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
