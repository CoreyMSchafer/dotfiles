#!/usr/bin/env zsh

xcode-select --install

echo "Complete the installation of Xcode Command Line Tools before proceeding."
echo "Press enter to continue..."
read

# Set scroll as traditional instead of natural
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Set the default Finder window location to the Documents folder
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Documents"

# Apply changes by restarting Finder
killall Finder

echo "Customize finder tool bar to only show view and search (Finder -> View -> Customize Toolbar...)"
echo "Remove recents from favorites and add Macintosh HD to locations"
echo "Change all directories to column view"
echo "Press enter to continue..."
read

# Hide Wi-Fi Icon (not working)
defaults write com.apple.controlcenter "NSStatusItem Visible WiFi" -bool false

# Hide Focus Icon (not working)
defaults write com.apple.controlcenter "NSStatusItem Visible DoNotDisturb" -bool false

# Hide Screen Mirroring Icon (not working)
defaults write com.apple.controlcenter "NSStatusItem Visible ScreenMirroring" -bool false

# Hide Display Icon (not working)
defaults write com.apple.controlcenter "NSStatusItem Visible Display" -bool false

# Hide Sound Icon (not working)
defaults write com.apple.controlcenter "NSStatusItem Visible Sound" -bool false

# Hide Now Playing Icon (not working)
defaults write com.apple.controlcenter "NSStatusItem Visible NowPlaying" -bool false

# Hide Spotlight Icon (not working)
defaults write com.apple.Spotlight "NSStatusItem Visible Item-0" -bool false

# Hide Siri Icon
defaults write com.apple.Siri StatusMenuVisible -bool false

# Enable Battery Percentage Display (not working)
defaults write com.apple.menuextra.battery ShowPercent -string "YES"

# Set location for screenshots
mkdir "${HOME}/Desktop/Screenshots"
defaults write com.apple.screencapture location "${HOME}/Desktop/Screenshots"

# Restart SystemUIServer to apply changes
killall SystemUIServer

# Turn on "Automatically hide and show the Dock"
defaults write com.apple.dock autohide -bool true

# Turn off "Show recent applications in Dock"
defaults write com.apple.dock show-recents -bool false

# Apply changes by restarting the Dock
killall Dock

# Set the Touch Bar to show the Expanded Control Strip by default
defaults write com.apple.touchbar.agent PresentationModeGlobal -string "fullControlStrip"

# Apply the changes (restart the Touch Bar agent)
killall ControlStrip

# Set desktop background image
osascript <<EOD
tell application "System Events"
    set thePicture to POSIX file "$(pwd)/Desktop.png"
    tell every desktop
        set picture to thePicture
    end tell
end tell
EOD
