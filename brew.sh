#!/usr/bin/env bash

# Install command-line tools using Homebrew.

# Ask for the administrator password upfront.
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade --all

brew tap homebrew/dupes

# Install GNU core utilities (those that come with OS X are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils
sudo ln -s /usr/local/bin/gsha256sum /usr/local/bin/sha256sum

# Install some other useful utilities like `sponge`.
brew install moreutils

# Install GNU `find`, `locate`, `updatedb`, and `xargs`.
brew install findutils --with-default-names

# Install other GNU utilities, overwriting the built-ins.
brew install gnu-sed --with-default-names
brew install gnu-tar --with-default-names
brew install gnu-which --with-default-names
brew install gnu-indent --with-default-names
brew install gnutls --with-default-names
brew install grep --with-default-names
brew install binutils
brew install diffutils
brew install gawk
brew install gzip
brew install screen
brew install watch
brew install wdiff --with-gettext

# Install `wget` with IRI support.
brew install wget --with-iri

# Install Bash 4.
# Note: don’t forget to add `/usr/local/bin/bash` to `/etc/shells` before
# running `chsh`.
brew install bash
brew tap homebrew/versions
brew install bash-completion2

# Install more recent versions of some OS X tools.
brew install vim --override-system-vi
brew install homebrew/dupes/grep
brew install homebrew/dupes/openssh
brew install homebrew/dupes/screen
brew install homebrew/dupes/lsof

# Install other useful binaries.
brew install git
brew install speedtest_cli
brew install ssh-copy-id
brew install testssl
brew install tree
brew install ruby
brew install openssh
brew install rsync
brew install gcc --enable-all-languages
brew install htop
brew install nmap
brew install gzip

# Remove outdated versions from the cellar.
brew cleanup
