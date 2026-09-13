############################
# Windows preferences — the macOS.sh counterpart. Dot-sourced by install.ps1 (elevated).
# Each setting checks before changing anything.
############################

# Screenshots (Win+Shift+S, Win+PrtScn) go to ~\Desktop\Screenshots, as on the Mac.
# The Screenshots known folder is the registry value named by its GUID; Explorer
# and the Snipping Tool read it from here. Takes effect for new captures right away.
$screenshotDir = Join-Path $HOME 'Desktop\Screenshots'
$shellFolders = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
$screenshotsGuid = '{B7BEDE81-DF94-4682-A7D8-57A52620B86F}'
New-Item -ItemType Directory -Force -Path $screenshotDir | Out-Null
$current = (Get-ItemProperty -Path $shellFolders -Name $screenshotsGuid -ErrorAction SilentlyContinue).$screenshotsGuid
if ([Environment]::ExpandEnvironmentVariables("$current") -eq $screenshotDir) {
    Write-Info 'Screenshot location is already set. Skipping.'
} else {
    New-ItemProperty -Path $shellFolders -Name $screenshotsGuid -Value '%USERPROFILE%\Desktop\Screenshots' -PropertyType ExpandString -Force | Out-Null
    Write-Info "Screenshots will now be saved to $screenshotDir."
}

# Explorer: show hidden files and file extensions (both hidden by default).
# Explorer re-reads these when it restarts, so restart it only if something changed.
$explorerAdvanced = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$explorerChanged = $false
foreach ($pair in @(@{ Name = 'Hidden'; Value = 1 }, @{ Name = 'HideFileExt'; Value = 0 })) {
    $existing = (Get-ItemProperty -Path $explorerAdvanced -Name $pair.Name -ErrorAction SilentlyContinue).($pair.Name)
    if ($existing -ne $pair.Value) {
        Set-ItemProperty -Path $explorerAdvanced -Name $pair.Name -Value $pair.Value -Type DWord
        $explorerChanged = $true
    }
}
if ($explorerChanged) {
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue # Windows restarts it
    Write-Info 'Explorer now shows hidden files and file extensions.'
} else {
    Write-Info 'Explorer already shows hidden files and file extensions. Skipping.'
}

# Long paths: lift the 260-character path limit (node_modules breaks it). Git has its own switch.
$fileSystem = 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem'
if ((Get-ItemProperty -Path $fileSystem -Name LongPathsEnabled -ErrorAction SilentlyContinue).LongPathsEnabled -eq 1) {
    Write-Info 'Long paths are already enabled. Skipping.'
} else {
    Set-ItemProperty -Path $fileSystem -Name LongPathsEnabled -Value 1 -Type DWord
    Write-Info 'Long paths enabled.'
}
if (Get-Command git -ErrorAction SilentlyContinue) { git config --global core.longpaths true }

# sudo for Windows (24H2+): `sudo <cmd>` from a normal shell, like the Mac.
# "normal" mode runs the command inline in the current window.
if (Get-Command sudo -ErrorAction SilentlyContinue) {
    if ((sudo config 2>$null) -match 'Inline mode') {
        Write-Info 'sudo is already enabled. Skipping.'
    } else {
        sudo config --enable normal | Out-Null
        Write-Info 'sudo enabled (inline mode).'
    }
} else {
    Write-Warn 'sudo for Windows is not available on this build (needs Windows 11 24H2 or later).'
}

# PowerToys: make sure Text Extractor (Win+Shift+T screen OCR) and Awake (caffeinate) are on.
# PowerToys writes settings.json on its first launch; until then the defaults (both on) apply.
$ptSettings = Join-Path $env:LOCALAPPDATA 'Microsoft\PowerToys\settings.json'
if (Test-Path $ptSettings) {
    $pt = Get-Content $ptSettings -Raw | ConvertFrom-Json
    $ptChanged = $false
    foreach ($module in 'TextExtractor', 'Awake') {
        if ($pt.enabled.$module -ne $true) {
            $pt.enabled | Add-Member -NotePropertyName $module -NotePropertyValue $true -Force
            $ptChanged = $true
        }
    }
    if ($ptChanged) {
        $pt | ConvertTo-Json -Depth 10 | Set-Content $ptSettings
        Write-Info 'PowerToys Text Extractor and Awake enabled.'
    } else {
        Write-Info 'PowerToys Text Extractor and Awake are already enabled. Skipping.'
    }
} else {
    Write-Info 'PowerToys has not run yet; Text Extractor and Awake are on by default.'
}
