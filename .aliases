# Shortcuts
alias ch='history | grep "git commit"'
alias hg='history | grep'
alias yt='subl ~/Google\ Drive/YouTube/Scripts/'
alias cyt='cd ~/Google\ Drive/YouTube/Scripts/'
alias oyt='open ~/Google\ Drive/YouTube/Scripts/'

# Detect which `ls` flavor is in use
if ls --color > /dev/null 2>&1; then # GNU `ls`
	colorflag="--color"
else # OS X `ls`
	colorflag="-G"
fi

# List all files colorized in long format, including dot files
alias la="ls -lahF ${colorflag}"

# Always use color output for `ls`
alias ls="command ls ${colorflag}"
export LS_COLORS='no=00:fi=00:di=04;35:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:'

export LSCOLORS='Gxfxcxdxbxegedabagacad'


# Always enable colored `grep` output
# Note: `GREP_OPTIONS="--color=auto"` is deprecated, hence the alias usage.
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Enable aliases to be sudo’ed
alias sudo='sudo '

# Get OS X Software Updates, and update installed Ruby gems, Homebrew, npm, and their installed packages
alias update_system='sudo softwareupdate -i -a'

# Show/hide hidden files in Finder
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# To prep before screencasts
alias tut_mode='defaults write com.apple.dock autohide -bool true && killall Dock;
               defaults write com.apple.finder CreateDesktop -bool false && killall Finder;
               defaults write com.apple.menuextra.clock IsAnalog -bool true && killall SystemUIServer;
               rm -rf ~/.Trash/*;
               rm -rf ~/Downloads/*'
alias reg_mode='defaults write com.apple.dock autohide -bool false && killall Dock;
               defaults write com.apple.finder CreateDesktop -bool true && killall Finder;
               defaults write com.apple.menuextra.clock IsAnalog -bool false && killall SystemUIServer;'

alias clean='rm -rf ~/.Trash/*; rm -rf ~/Downloads/*'
alias wipe_env='rm -rf ~/tutorial_env; python3 -m venv ~/tutorial_env'
alias tut_env='source ~/tutorial_env/bin/activate'
