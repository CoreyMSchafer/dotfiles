#!/usr/bin/env zsh
############################
# macOS system settings.
# Safe to re-run: settings are only written (and the affected system UI
# only restarted) when the current value differs.
# Some settings rely on undocumented "magic" values that can change between
# macOS releases — periodically check that each still does what it says.
############################

set -euo pipefail

# The folder this script lives in (:A = absolute path, :h = parent dir)
SCRIPT_DIR="${0:A:h}"
source "${SCRIPT_DIR}/helpers.sh"

# Xcode Command Line Tools (git, compilers — needed by Homebrew)
if xcode-select -p &>/dev/null; then
    info "Xcode Command Line Tools are already installed. Skipping."
else
    xcode-select --install
    pause_for "Complete the installation of Xcode Command Line Tools before proceeding."
fi

# Set scroll as traditional instead of natural
# Note: this is a global preference; a logout/restart is required for it to take effect.
if [[ "$(defaults read NSGlobalDomain com.apple.swipescrolldirection 2>/dev/null || true)" != "0" ]]; then
    defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
    info "Set scroll direction to traditional (takes effect after logout/restart)."
else
    info "Scroll direction is already set to traditional. Skipping."
fi

# Set location for screenshots
SCREENSHOT_DIR="${HOME}/Desktop/Screenshots"
mkdir -p "${SCREENSHOT_DIR}"
if [[ "$(defaults read com.apple.screencapture location 2>/dev/null || true)" != "${SCREENSHOT_DIR}" ]]; then
    defaults write com.apple.screencapture location "${SCREENSHOT_DIR}"
    killall SystemUIServer &>/dev/null || true
    info "Screenshots will now be saved to ${SCREENSHOT_DIR}."
else
    info "Screenshot location is already set. Skipping."
fi

# Add Bluetooth to Menu Bar for battery percentages
# (stored per-host by Control Center; 2 = show in menu bar)
if [[ "$(defaults -currentHost read com.apple.controlcenter Bluetooth 2>/dev/null || true)" != "2" ]]; then
    defaults -currentHost write com.apple.controlcenter Bluetooth -int 2
    killall ControlCenter &>/dev/null || true
    info "Added Bluetooth to the menu bar."
else
    info "Bluetooth is already in the menu bar. Skipping."
fi

# Set the desktop background to the image used in my tutorials
# (skipped when desktop 1 already shows it)
IMAGE_PATH="${SCRIPT_DIR}/settings/Desktop.png"
if [[ ! -f "${IMAGE_PATH}" ]]; then
    warn "Desktop image not found at ${IMAGE_PATH}. Skipping desktop background."
elif [[ "$(osascript -e 'tell application "System Events" to get picture of desktop 1' 2>/dev/null || true)" == "${IMAGE_PATH}" ]]; then
    info "Desktop background is already set. Skipping."
else
    if ! osascript <<EOF
tell application "System Events"
    set desktopCount to count of desktops
    repeat with desktopNumber from 1 to desktopCount
        tell desktop desktopNumber
            set picture to "$IMAGE_PATH"
        end tell
    end repeat
end tell
EOF
    then
        warn "Could not set the desktop background (System Events may need Automation permission)."
    else
        info "Desktop background set."
    fi
fi
