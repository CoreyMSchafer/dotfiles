# Create Sublime Text directories as they don't exist until Sublime is opened
mkdir -p ~/Library/Application\ Support/Sublime\ Text\ 3/Installed\ Packages/Package\
mkdir -p ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/

# Install Package Control
curl "https://packagecontrol.io/Package%20Control.sublime-package" > settings/Package\ Control.sublime-package
cp -r settings/Package\ Control.sublime-package ~/Library/Application\ Support/Sublime\ Text\ 3/Installed\ Packages/Package\ Control.sublime-package

# Install Custom Sublime Text settings
cp -r settings/Preferences.sublime-settings ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Preferences.sublime-settings
cp -r settings/Anaconda.sublime-settings ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Anaconda.sublime-settings
cp -r settings/Default\ \(OSX\).sublime-keymap ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Default\ \(OSX\).sublime-keymap

# Create Python Build Systems
cp -r settings/Python-2.sublime-build ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/
cp -r settings/Python-3.sublime-build ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/

# Custom Settings For Theme
cp -r settings/Material-Theme-Darker.sublime-theme ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/

# Create symlink to subl command
ln -s /Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl /usr/local/bin/subl
