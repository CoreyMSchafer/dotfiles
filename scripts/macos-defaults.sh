#!/usr/bin/env bash
# Vernünftige macOS-Defaults. Konservativ gehalten. Abmelden/Neustart für alles.
set -euo pipefail

# Tastatur: schnelle Wiederholrate (gut für vim/tmux-Navigation)
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Finder: Pfadleiste, Statusleiste, alle Endungen, versteckte Dateien
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"   # Listenansicht
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Screenshots gesammelt in ~/Pictures/Screenshots
mkdir -p "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture type -string "png"

# Dock: keine zuletzt benutzten Apps, kein Auto-Hide-Delay
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock autohide-delay -float 0

# Textbearbeitung: keine Auto-Korrektur/Smart-Quotes (stört beim Coden)
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

killall Finder Dock 2>/dev/null || true
echo "macOS-Defaults gesetzt (einige greifen erst nach Ab-/Anmelden)."
echo
echo "Noch manuell (einmalig, überlebt Neustarts):"
echo "  • Caps Lock -> Control:  Systemeinstellungen > Tastatur > Sondertasten"
echo "    (größter Gewinn für vim/tmux). Sofort testen ohne Neustart:"
echo "    hidutil property --set '\''{\"UserKeyMapping\":[{\"HIDKeyboardModifierMappingSrc\":0x700000039,\"HIDKeyboardModifierMappingDst\":0x7000000E0}]}'\''"
echo "  • FileVault aktivieren:  Systemeinstellungen > Datenschutz & Sicherheit"
echo "    (wichtig, sobald der iMac per Tailscale erreichbar ist)"
