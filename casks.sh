#!/usr/bin/env bash

################################################
bot "Setting up >Homebrew Cask<"
################################################
promptSudo
running "checking brew-cask install"
output=$(brew tap | grep cask)
if [[ $? != 0 ]]; then
  require_brew caskroom/cask/brew-cask
else
  echo -n "already installed "
fi
brew tap caskroom/versions > /dev/null 2>&1
ok; botdone


################################################
bot "Setting up >Atom<"
################################################
require_cask atom

# emulate the 'install shell commands' from inside atom
running "Installing Atom Shell Tools"
sudo rm /usr/local/bin/apm
ln -s /Applications/Atom.app/Contents/Resources/app/apm/node_modules/.bin/apm /usr/local/bin/apm
sudo rm /usr/local/bin/atom
ln -s /Applications/Atom.app/Contents/Resources/app/atom.sh /usr/local/bin/atom;ok

running "symlinking atom dotfiles"; filler
pushd ~ > /dev/null 2>&1
symlinkifne .atom/config.cson
symlinkifne .atom/init.coffee
symlinkifne .atom/keymap.cson
symlinkifne .atom/snippets.cson
symlinkifne .atom/styles.less
popd > /dev/null 2>&1
ok

running "Installing packages"; filler
# strip packages of versions
sed -i 's/@.*//' ./configs/atom-packages.txt
apm install --packages-file ./configs/atom-packages.txt;ok
# require_apm linter
# require_apm linter-eslint
# require_apm atom-beautify

botdone


###############################################################################
bot "Setting up >iTerm2<"
###############################################################################
require_cask iterm2

running "Copying pre-set definitions"
yes | cp -rf ./configs/iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist

running "Installing the Solarized Dark theme for iTerm (opening file)"
# copy preferences so we can convert to XML
cp ~/Library/Preferences/com.googlecode.iterm2.plist ./temp.iterm2.plist
plutil -convert xml1 temp.iterm2.plist
if ! grep -F "Solarized" temp.iterm2.plist
then
  open "./configs/Solarized Dark.itermcolors"
fi
rm temp.iterm2.plist
ok

running "Don’t display the annoying prompt when quitting iTerm"
defaults write com.googlecode.iterm2 PromptOnQuit -bool false;ok

running "hide tab title bars"
defaults write com.googlecode.iterm2 HideTab -bool true;ok

# running "set system-wide hotkey to show/hide iterm with ^\`"
# defaults write com.googlecode.iterm2 Hotkey -bool true;
# defaults write com.googlecode.iterm2 HotkeyChar -int 96;
# defaults write com.googlecode.iterm2 HotkeyCode -int 50;
# defaults write com.googlecode.iterm2 HotkeyModifiers -int 262401;ok

# running "Make iTerm2 load new tabs in the same directory"
# defaults export com.googlecode.iterm2 /tmp/plist
# /usr/libexec/PlistBuddy -c "set \"New Bookmarks\":0:\"Custom Directory\" Recycle" /tmp/plist
# defaults import com.googlecode.iterm2 /tmp/plist;ok

botdone


###############################################################################
bot "Setting up >Google Chrome<"
###############################################################################
require_cask google-chrome

running "Allow installing user scripts via GitHub Gist or Userscripts.org"
defaults write com.google.Chrome ExtensionInstallSources -array "https://gist.githubusercontent.com/" "http://userscripts.org/*"

running "Use the system-native print preview dialog"
defaults write com.google.Chrome DisablePrintPreview -bool true;ok

running "Expand the print dialog by default"
defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true;ok

botdone


###############################################################################
bot "Setting up >Transmission<"
###############################################################################
require_cask transmission

running "Use '~/Downloads' to store incomplete downloads"
defaults write org.m0k.transmission UseIncompleteDownloadFolder -bool true;ok
defaults write org.m0k.transmission IncompleteDownloadFolder -string "${HOME}/Downloads";ok

running "Don’t prompt for confirmation before downloading"
defaults write org.m0k.transmission DownloadAsk -bool false;ok

running "Trash original torrent files"
defaults write org.m0k.transmission DeleteOriginalTorrent -bool true;ok

running "Hide the donate message"
defaults write org.m0k.transmission WarningDonate -bool false;ok

running "Hide the legal disclaimer"
defaults write org.m0k.transmission WarningLegal -bool false;ok

botdone


###############################################################################
bot "Installing remaining casks"
###############################################################################

require_cask virtualbox
require_cask sqlitebrowser
require_cask dockertoolbox
require_cask dropbox
require_cask the-unarchiver
require_cask vlc
require_cask cheatsheet
require_cask apptrap
require_cask asepsis
require_cask smcfancontrol
require_cask spotify
require_cask basictex
require_cask gimp
require_cask mendeley-desktop
require_cask skype
require_cask kext-utility
require_cask teamviewer

# commented out casks
#require_cask diffmerge
#require_cask slack
#require_cask sizeup
#require_cask breach
#require_cask firefox
#require_cask firefox-aurora
#require_cask google-chrome-canary
#require_cask torbrowser
#require_cask chefdk
# vagrant for running dev environments using docker images
#require_cask vagrant # # | grep Caskroom | sed "s/.*'\(.*\)'.*/open \1\/Vagrant.pkg/g" | sh


# Cracked applications - I've yet to find a solution
# $ brew cask install alfred
# brew cask alfred link


################################################
bot "Installing >Quicklook plugins<"
################################################
require_cask qlcolorcode
require_cask qlstephen
require_cask qlmarkdown
require_cask quicklook-json
require_cask qlprettypatch
require_cask quicklook-csv
require_cask betterzipql
require_cask qlimagesize
botdone
