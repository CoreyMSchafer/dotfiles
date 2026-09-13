#!/usr/bin/env zsh
############################
# macOS system settings. Safe to re-run: each setting is written (and its
# UI restarted) only when the current value differs. Some values are
# undocumented "magic" numbers — recheck them after macOS upgrades.
############################

set -euo pipefail

# This script's folder (:A absolute, :h parent)
SCRIPT_DIR="${0:A:h}"
source "${SCRIPT_DIR}/helpers.sh"

# Computer name (Enter keeps the current one). ComputerName is the display name;
# the network names (LocalHostName, HostName) get a lowercase hyphenated form.
if [[ -n "${DOTFILES_NO_INPUT:-}" ]]; then
    info "Skipping the computer-name prompt (DOTFILES_NO_INPUT)."
else
    current_name="$(scutil --get ComputerName)"
    read -r "new_name?Computer name [${current_name}] (Enter to keep): "
    if [[ -n "${new_name}" && "${new_name}" != "${current_name}" ]]; then
        # "Corey's iMac" -> coreys-imac (drop apostrophes, everything else non-alphanumeric becomes a hyphen)
        host_name="$(printf '%s' "${new_name}" | tr -d "'" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | sed 's/^-*//; s/-*$//')"
        sudo scutil --set ComputerName "${new_name}"
        sudo scutil --set LocalHostName "${host_name}"
        sudo scutil --set HostName "${host_name}"
        info "Computer name set to ${new_name} (${host_name} on the network)."
    else
        info "Computer name stays ${current_name}."
    fi
fi

# Xcode Command Line Tools (git, compilers — needed by Homebrew)
if xcode-select -p &>/dev/null; then
    info "Xcode Command Line Tools are already installed. Skipping."
else
    xcode-select --install
    info "Complete the Xcode Command Line Tools installation in the dialog; waiting..."
    until xcode-select -p &>/dev/null; do sleep 5; done
    info "Xcode Command Line Tools installed."
fi

# Traditional (non-"natural") scrolling; takes effect after logout
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

# Bluetooth in the menu bar (per-host Control Center setting; 2 = show)
if [[ "$(defaults -currentHost read com.apple.controlcenter Bluetooth 2>/dev/null || true)" != "2" ]]; then
    defaults -currentHost write com.apple.controlcenter Bluetooth -int 2
    killall ControlCenter &>/dev/null || true
    info "Added Bluetooth to the menu bar."
else
    info "Bluetooth is already in the menu bar. Skipping."
fi

# Desktop background used in my tutorials (skipped if desktop 1 already has it)
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

# Accept COLORTERM from SSH clients so prompts get exact colors when SSHing
# into this Mac. A drop-in file survives macOS updates.
SSHD_DROPIN="/etc/ssh/sshd_config.d/200-colorterm.conf"
if [[ "$(cat "${SSHD_DROPIN}" 2>/dev/null)" == "AcceptEnv COLORTERM" ]]; then
    info "sshd already accepts COLORTERM. Skipping."
else
    echo "AcceptEnv COLORTERM" | sudo tee "${SSHD_DROPIN}" >/dev/null
    info "sshd will accept COLORTERM from SSH clients (${SSHD_DROPIN})."
fi
