############################
# Windows preferences - the macOS.sh counterpart. Dot-sourced by install.ps1 (elevated).
# Each setting checks before changing anything.
############################

# Screenshots (Win+Shift+S, Win+PrtScn) go to ~\Desktop\Screenshots, as on the Mac.
# The known folder is a registry value named by its GUID; takes effect right away.
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

# Explorer: show hidden files and file extensions, and no Snap Assist (the "pick another
# window" popup after snapping). Explorer re-reads these on restart, so restart it only on a change.
$explorerAdvanced = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$explorerChanged = $false
foreach ($pair in @(@{ Name = 'Hidden'; Value = 1 }, @{ Name = 'HideFileExt'; Value = 0 }, @{ Name = 'SnapAssist'; Value = 0 })) {
    $existing = (Get-ItemProperty -Path $explorerAdvanced -Name $pair.Name -ErrorAction SilentlyContinue).($pair.Name)
    if ($existing -ne $pair.Value) {
        Set-ItemProperty -Path $explorerAdvanced -Name $pair.Name -Value $pair.Value -Type DWord
        $explorerChanged = $true
    }
}
if ($explorerChanged) {
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue # Windows restarts it
    Write-Info 'Explorer now shows hidden files and file extensions; Snap Assist is off.'
} else {
    Write-Info 'Explorer already shows hidden files and file extensions, Snap Assist off. Skipping.'
}

# PowerToys Keyboard Manager remaps from settings\keyboard-manager.json (Win+Shift+4 ->
# Win+Shift+S, the Mac screenshot chord). Key codes: 260 = Win, 16 = Shift, then the key.
# The module toggle is read at PowerToys startup, so it restarts on a change; the remap file is watched.
$ptSettings = "$env:LOCALAPPDATA\Microsoft\PowerToys\settings.json"
$kbmDir = "$env:LOCALAPPDATA\Microsoft\PowerToys\Keyboard Manager"
$pt = if (Test-Path $ptSettings) { Get-Content $ptSettings -Raw | ConvertFrom-Json }
if (-not $pt -or -not $pt.enabled) {
    Write-Warn 'PowerToys settings not found or empty (open PowerToys Settings once, then re-run for the Keyboard Manager remaps).'
} else {
    if ($pt.enabled.'Keyboard Manager' -ne $true) {
        # PowerToys keeps its settings file open (writing behind it truncates the file), so stop it first
        Stop-Process -Name 'PowerToys*' -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        $pt.enabled | Add-Member -NotePropertyName 'Keyboard Manager' -NotePropertyValue $true -Force
        $pt | ConvertTo-Json -Depth 32 | Set-Content $ptSettings -Encoding utf8
        if ($env:SSH_CONNECTION) { Write-Warn 'PowerToys Keyboard Manager enabled; reopen PowerToys from the Start menu (an SSH session cannot start it on the desktop).' }
        else { Start-Process "$env:LOCALAPPDATA\PowerToys\PowerToys.exe"; Write-Info 'PowerToys Keyboard Manager enabled.' }
    }
    New-Item -ItemType Directory -Force $kbmDir | Out-Null
    $wanted = Get-Content "$PSScriptRoot\settings\keyboard-manager.json" -Raw | ConvertFrom-Json
    $kbmFile = "$kbmDir\default.json"
    $kbm = if (Test-Path $kbmFile) { Get-Content $kbmFile -Raw | ConvertFrom-Json } else { $wanted }
    $have = @($kbm.remapShortcuts.global | ForEach-Object { $_.originalKeys })
    $missing = @($wanted.remapShortcuts.global | Where-Object { $_.originalKeys -notin $have })
    if ($missing.Count -gt 0 -or -not (Test-Path $kbmFile)) {
        $kbm.remapShortcuts.global = @($kbm.remapShortcuts.global) + $missing
        $kbm | ConvertTo-Json -Depth 8 | Set-Content $kbmFile -Encoding utf8
        Write-Info 'Keyboard Manager: Win+Shift+4 now takes a region snip (Win+Shift+S).'
    } else { Write-Info 'Keyboard Manager remaps already in place. Skipping.' }
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
    if ((Get-CommandOutput { sudo config }) -match 'Inline mode') {
        Write-Info 'sudo is already enabled. Skipping.'
    } else {
        sudo config --enable normal | Out-Null
        Write-Info 'sudo enabled (inline mode).'
    }
} else {
    Write-Warn 'sudo for Windows is not available on this build (needs Windows 11 24H2 or later).'
}

# Desktop background used in my tutorials (settings/Desktop.png, as on the Mac).
# SystemParametersInfo applies it live (needs a desktop session; fails over SSH).
$wallpaper = Join-Path (Split-Path -Parent $PSScriptRoot) 'settings\Desktop.png'
if (-not (Test-Path $wallpaper)) {
    Write-Warn "Desktop image not found at $wallpaper. Skipping desktop background."
} elseif ((Get-ItemProperty 'HKCU:\Control Panel\Desktop').Wallpaper -eq $wallpaper) {
    Write-Info 'Desktop background is already set. Skipping.'
} else {
    # Windows Spotlight (rotating backgrounds) would override it
    $spotlight = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\DesktopSpotlight\Settings'
    if (Test-Path $spotlight) { Set-ItemProperty $spotlight -Name EnabledState -Value 0 -Type DWord }
    Set-ItemProperty 'HKCU:\Control Panel\Desktop' -Name WallpaperStyle -Value '10' # 10 = Fill
    Set-ItemProperty 'HKCU:\Control Panel\Desktop' -Name TileWallpaper -Value '0'
    Add-Type -Namespace Dotfiles -Name Wallpaper -MemberDefinition '[DllImport("user32.dll", SetLastError = true)] public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);'
    if ([Dotfiles.Wallpaper]::SystemParametersInfo(0x0014, 0, $wallpaper, 0x03)) { # SPI_SETDESKWALLPAPER, update ini + broadcast
        Write-Info 'Desktop background set.'
    } else {
        Write-Warn 'Could not set the desktop background (needs a logged-in desktop session; run the script from Terminal).'
    }
}
