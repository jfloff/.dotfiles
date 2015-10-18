#!/usr/bin/env bash

################################################
bot "Setting up >Homebrew Cask<"
################################################
running "checking brew-cask install"
output=$(brew tap | grep cask)
if [[ $? != 0 ]]; then
  require_brew caskroom/cask/brew-cask
else
  echo -n "already installed "
fi
brew tap caskroom/versions > /dev/null 2>&1
ok; botdone


###############################################################################
bot "Setting up >Google Chrome<"
###############################################################################
require_cask google-chrome

running "Allow installing user scripts via GitHub Gist or Userscripts.org"
defaults write com.google.Chrome ExtensionInstallSources -array "https://gist.githubusercontent.com/" "http://userscripts.org/*";ok

running "Use the system-native print preview dialog"
defaults write com.google.Chrome DisablePrintPreview -bool true;ok

running "Expand the print dialog by default"
defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true;ok

botdone


################################################
bot "Setting up >Atom<"
################################################
# Rememver: cask already install the shell tools
require_cask atom

# theres instances when the .atom folder is not createad right away
if [[ ! -e ~/.atom ]]; then
    mkdir ~/.atom
fi

running "symlinking atom dotfiles"; filler
pushd ~ > /dev/null 2>&1
symlinkifne .atom/config.cson
symlinkifne .atom/init.coffee
symlinkifne .atom/keymap.cson
symlinkifne .atom/snippets.cson
symlinkifne .atom/styles.less
popd > /dev/null 2>&1

running "Installing & updating packages"; filler
# strip packages of versions
sed -i 's/@.*//' ./configs/atom-packages.txt > /dev/null 2>&1
apm install --packages-file ./configs/atom-packages.txt;ok
botdone


###############################################################################
bot "Setting up >iTerm2<"
###############################################################################
require_cask iterm2

running "Copying pre-set definitions"
yes | cp -rf ./configs/iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist;ok

running "Installing the Solarized Dark theme for iTerm (opening file)"
if ! grep -F "Solarized" ~/Library/Preferences/com.googlecode.iterm2.plist
then
  open "./configs/Solarized Dark.itermcolors"
fi > /dev/null 2>&1
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
bot "Setting up >Transmission<"
###############################################################################
require_cask transmission

running "Use '~/Downloads' to store incomplete downloads"
defaults write org.m0k.transmission UseIncompleteDownloadFolder -bool true
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
bot "Setting up >The Unarchiver<"
###############################################################################
require_cask the-unarchiver
# opens and closes unarchiver untill the preferences are loaded
uncpath=`whichapp 'The Unarchiver'`
open "$uncpath"
# waiting for The Unarchiver to create file
while true; do
  sleep 1
  [ ! -f ~/Library/Containers/cx.c3.theunarchiver/Data/Library/Preferences/cx.c3.theunarchiver.plist ] || break
done
killall 'The Unarchiver'

running "Set to extract archives to same folder as the archive"
defaults write ~/Library/Containers/cx.c3.theunarchiver/Data/Library/Preferences/cx.c3.theunarchiver.plist extractionDestination -int 1;ok

running "Set the modification date of the created folder to the modification date of the archive file"
defaults write ~/Library/Containers/cx.c3.theunarchiver/Data/Library/Preferences/cx.c3.theunarchiver.plist folderModifiedDate -int 2;ok

running "Delete archive after extraction"
defaults write ~/Library/Containers/cx.c3.theunarchiver/Data/Library/Preferences/cx.c3.theunarchiver.plist deleteExtractedArchive -bool true;ok

running "Do not open folder afer extraction"
defaults write ~/Library/Containers/cx.c3.theunarchiver/Data/Library/Preferences/cx.c3.theunarchiver.plist openExtractedFolder -bool false;ok

botdone

###############################################################################
bot "Installing >Mendeley<"
###############################################################################
require_cask mendeley-desktop

running "Enabling Bibtex sync"
defaults write com.mendeley.Mendeley\ Desktop BibtexSync.enabled -bool true;ok

running "Escape special charts"
defaults write com.mendeley.Mendeley\ Desktop Bibtex.escapeSpecialChars -bool true;ok

running "Disable publication abbreviations"
defaults write com.mendeley.Mendeley\ Desktop Bibtex.usePublicationAbbreviations -bool false;ok

running "Setting Bibtex sync as a one-file type"
defaults write com.mendeley.Mendeley\ Desktop BibtexSync.syncMode -string "SingleFile";ok

running "Setting Bibtex sync folder"
defaults write com.mendeley.Mendeley\ Desktop BibtexSync.path -string "~/Dropbox/PhD Loff/rw";ok
botdone

###############################################################################
bot "Installing >smcFanControl<"
###############################################################################
require_cask smcfancontrol

# opens and closes unarchiver untill the preferences are loaded
smcpath=`whichapp 'smcFanControl'`
open "$smcpath"
# waiting for smcFanControl to create file
while true; do
  sleep 1
  [ ! -f ~/Library/Preferences/com.eidac.smcFanControl2.plist ] || break
done
killall 'smcFanControl'

running "Start at login"
defaults write com.eidac.smcFanControl2 AutoStart -bool true; ok

running "Disable donation message"
defaults write com.eidac.smcFanControl2 DonationMessageShown -bool true; ok

running "Check updates automatically"
defaults write com.eidac.smcFanControl2 SUCheckAtStartup -bool true
defaults write com.eidac.smcFanControl2 SUEnableAutomaticChecks -bool true; ok

running "Adding 'Extreme RPM' profile"
# checking if current preferences already have a extreme profile
if ! grep -F "Extreme" ~/Library/Preferences/com.eidac.smcFanControl2.plist
then
  defaults write com.eidac.smcFanControl2 Favorites -array-add '
    {
      FanData = (
          {
              Description = "Left Fan";
              Maxspeed = 6000;
              Minspeed = 2000;
              menu = 1;
              selspeed = 6000;
          },
          {
              Description = "Right Fan";
              Maxspeed = 6000;
              Minspeed = 2000;
              selspeed = 6000;
          }
      );
      Standard = 0;
      Title = "Extreme RPM";
  }'
fi > /dev/null 2>&1
ok

botdone


###############################################################################
bot "Installing >Dropbox<"
###############################################################################
require_cask dropbox

running "Remove Dropbox’s green checkmark icons in Finder"
file=/Applications/Dropbox.app/Contents/Resources/emblem-dropbox-uptodate.icns
[ -e "${file}" ] && mv -f "${file}" "${file}.bak";ok

botdone


###############################################################################
bot "Installing remaining casks"
###############################################################################
require_cask spotify
require_cask dockertoolbox
require_cask sqlitebrowser
require_cask vlc
require_cask cheatsheet
# not working under El Capitan :(
#require_cask asepsis
require_cask basictex
require_cask skype
#require_cask kext-utility
require_cask teamviewer
require_cask gimp
require_cask alinof-timer

require_cask apptrap
# running "Add to system startup"
# if ! grep -F "AppTrap" ~/Library/Preferences/com.apple.loginitems.plist
# then
#   osascript -e 'tell application "System Events" to make new login item at end with properties {path:"/Applications/AppTrap.app", name:"AppTrap", hidden:true}';ok
# fi > /dev/null 2>&1
# ok;

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
