#!/usr/bin/env bash

#####
# install homebrew
#####

running "checking homebrew install"
brew_bin=$(which brew) 2>&1 > /dev/null
if [[ $? != 0 ]]; then
  action "installing homebrew"
    xcode-select --install
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    if [[ $? != 0 ]]; then
      error "unable to install homebrew, script $0 abort!"
      exit -1
  fi
fi
ok

#####
# install homebrew cask
#####
running "checking brew-cask install"
output=$(brew tap | grep cask)
if [[ $? != 0 ]]; then
  action "installing brew-cask"
  require_brew caskroom/cask/brew-cask
  export HOMEBREW_CASK_OPTS="--appdir=/Applications"
fi
ok

###############################################################################
#Install command-line tools using Homebrew                                    #
###############################################################################
# Make sure we’re using the latest Homebrew
running "updating homebrew"
brew update
ok

bot "before installing brew packages, we can upgrade any outdated packages."
read -r -p "run brew upgrade? [y|N] " response
if [[ $response =~ ^(y|yes|Y) ]];then
    # Upgrade any already-installed formulae
    action "upgrade brew packages..."
    brew upgrade
    ok "brews updated..."
else
    ok "skipped brew package upgrades.";
fi

bot "installing homebrew command-line tools"


# Install GNU core utilities (those that come with OS X are outdated)
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
require_brew coreutils
sudo ln -s /usr/local/bin/gsha256sum /usr/local/bin/sha256sum
# Install some other useful utilities like `sponge`
require_brew moreutils
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed
require_brew findutils

# Install Bash 4
# Note: don’t forget to add `/usr/local/bin/bash` to `/etc/shells` before running `chsh`.
#install bash
#install bash-completion

# Install RingoJS and Narwhal
# Note that the order in which these are installed is important; see http://git.io/brew-narwhal-ringo.
#install ringojs
#install narwhal

# Install other useful binaries
require_brew ack
# Beanstalk http://kr.github.io/beanstalkd/
#require_brew beanstalkd
# ln -sfv /usr/local/opt/beanstalk/*.plist ~/Library/LaunchAgents
# launchctl load ~/Library/LaunchAgents/homebrew.mxcl.beanstalk.plist

# dos2unix converts windows newlines to unix newlines
require_brew dos2unix
# fortune command--I source this as a better motd :)
require_brew fortune
require_brew gawk
# skip those GUI clients, git command-line all the way
require_brew git
# yes, yes, use git-flow, please :)
require_brew git-flow
# Install GNU `sed`, overwriting the built-in `sed`
# so we can do "sed -i 's/foo/bar/' file" instead of "sed -i '' 's/foo/bar/' file"
require_brew gnu-sed --default-names
# better, more recent grep
require_brew homebrew/dupes/grep
require_brew hub
# jq is a JSON grep
require_brew jq
# better/more recent version of screen
require_brew tree
# better, more recent vim
require_brew vim --override-system-vi
require_brew watch
# Install wget with IRI support
require_brew wget --with-iri
require_brew rename

###############################################################################
# Native Apps (via brew cask)                                                 #
###############################################################################
bot "installing GUI tools via homebrew casks..."
brew tap caskroom/versions > /dev/null 2>&1

# cloud storage
#require_cask amazon-cloud-drive
#require_cask box-sync
require_cask dropbox

# communication
#require_cask slack

# im replacing caffeine with caffeinate from alfred
#require_cask caffeine

# tools
#require_cask diffmerge
require_cask iterm2
#require_cask sizeup

require_cask atom
# require_apm linter
# require_apm linter-eslint
# require_apm atom-beautify

require_cask the-unarchiver
require_cask transmission
require_cask vlc
#require_cask xquartz

# development browsers
#require_cask breach
#require_cask firefox
#require_cask firefox-aurora
require_cask google-chrome
#require_cask google-chrome-canary
#require_cask torbrowser

# virtal machines
#require_cask virtualbox
# chef-dk, berkshelf, etc
#require_cask chefdk
# vagrant for running dev environments using docker images
#require_cask vagrant # # | grep Caskroom | sed "s/.*'\(.*\)'.*/open \1\/Vagrant.pkg/g" | sh

require_cask cheatsheet
require_cask atom
require_cask apptrap
require_cask asepsis
require_cask smcfancontrol
require_cask spotify
require_cask basictex
require_cask gimp
require_cask mendeley-desktop
require_cask skype
require_cask sqlitebrowser
require_cask dockertoolbox
require_cask kext-utility
require_cask teamviewer
require_cask virtualbox

# Cracked applications - I've yet to find a solution
# $ brew cask install alfred
# brew cask alfred link

bot "Installing Quicklook plugins"
require_cask qlcolorcode
require_cask qlstephen
require_cask qlmarkdown
require_cask quicklook-json
require_cask qlprettypatch
require_cask quicklook-csv
require_cask betterzipql
require_cask qlimagesize

bot "Alright, cleaning up homebrew cache..."
# Remove outdated versions from the cellar
brew cleanup > /dev/null 2>&1
brew cask cleanup > /dev/null 2>&1
bot "All clean"
