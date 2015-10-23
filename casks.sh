#!/usr/bin/env bash

################################################
bot "Setting up >Homebrew Cask<"
################################################
running "checking brew-cask install"
output=$(brew tap | grep cask)
if [[ $? != 0 ]]; then
  filler
  require_brew caskroom/cask/brew-cask
else
  echo -n "already installed "
fi
brew tap caskroom/versions > /dev/null 2>&1
ok; botdone


###############################################################################
bot "Setting up >Google Chrome<"
###############################################################################
# checks if google chrome was already installed
firstinstall=`brew cask list | grep "google-chrome" &> /dev/null ; echo $?`

require_cask google-chrome

running "Allow installing user scripts via GitHub Gist or Userscripts.org"
defaults write com.google.Chrome ExtensionInstallSources -array "https://gist.githubusercontent.com/" "http://userscripts.org/*";ok

running "Use the system-native print preview dialog"
defaults write com.google.Chrome DisablePrintPreview -bool true;ok

running "Expand the print dialog by default"
defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true;ok

# if first installation, opens
if [ $firstinstall == 1 ]; then
  open "/Applications/Google Chrome.app"
fi
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
symlinkifne .atom/packages.cson
symlinkifne .atom/styles.less
popd > /dev/null 2>&1

running "Installing & updating packages"; filler
# strip packages file
atom_packages=$(mktemp /tmp/dotfiles.atom_packages.XXXXXXXXXX)
cat .atom/packages.cson | sed '$ d' | sed '1,1d' | sed 's/\"//g' > $atom_packages
apm install --packages-file $atom_packages

botdone


###############################################################################
bot "Setting up >iTerm2<"
###############################################################################
require_cask iterm2

if [ $TERM_PROGRAM == 'iTerm.app' ]; then
  warn "You are running this script from inside iTerm. Some settings might not work. Run form Terminal to apply correctly"
fi

# opens and closes untill the preferences are loaded
if [ ! -f ~/Library/Preferences/com.googlecode.iterm2.plist ]; then
  open "/Applications/iTerm.app"
  # waiting for it to create plist file
  while true; do
    sleep 1
    [ ! -f ~/Library/Preferences/com.googlecode.iterm2.plist ] || break
  done
  killall -9 "iTerm" &> /dev/null
fi

# enabling some settings that are useful when we are installing iterm for the first time
# so we can open for profiles preferences
running "Activate automatic updates"
defaults write com.googlecode.iterm2 SUEnableAutomaticChecks -bool true;ok

running "Disable crash reporter"
defaults write com.googlecode.iterm2 UKCrashReporterLastCrashReportDate -int 2147483647;ok

running "Don’t display the annoying prompt when quitting iTerm"
defaults write com.googlecode.iterm2 PromptOnQuit -bool false;ok

  # opens and closes unarchiver untill the preferences are loaded
if ! grep -F "New Bookmarks" ~/Library/Preferences/com.googlecode.iterm2.plist &> /dev/null; then
  open "/Applications/iTerm.app"
  # opens preferences so plist loads the profiles settings
  osascript -e 'tell application "System Events" to keystroke "," using {command down}'
  osascript -e 'tell application "System Events" to keystroke "w" using {command down}'
  # waits for it to create the bookmarks preferences
  while true; do
    sleep 1
    ! grep -F "New Bookmarks" ~/Library/Preferences/com.googlecode.iterm2.plist || break
  done &> /dev/null

  if [ $TERM_PROGRAM != 'iTerm.app' ]; then
    killall -9 "iTerm" &> /dev/null
  fi
fi

running "Hide tab title bars"
defaults write com.googlecode.iterm2 HideTab -bool true;ok

running "Enable past from clipboard"
defaults write com.googlecode.iterm2 PasteFromClipboard -bool false;ok

running "set system-wide hotkey to show/hide iterm with '⌘ +⌥ +t'"
defaults write com.googlecode.iterm2 Hotkey -bool true
defaults write com.googlecode.iterm2 HotkeyChar -int 116
defaults write com.googlecode.iterm2 HotkeyCode -int 17
defaults write com.googlecode.iterm2 HotkeyModifiers -int 1573160;ok

running "Disable Growl Notifications"
/usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:BM\ Growl false" ~/Library/Preferences/com.googlecode.iterm2.plist;ok

running "Silences terminal bell"
/usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Silence\ Bell true" ~/Library/Preferences/com.googlecode.iterm2.plist;ok

running "Set window style to be at top of the screen"
/usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Window\ Type 2" ~/Library/Preferences/com.googlecode.iterm2.plist;ok

running "Make iTerm2 load new tabs in the same directory"
/usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Custom\ Directory Recycle" ~/Library/Preferences/com.googlecode.iterm2.plist;ok

# http://elweb.co/making-iterm-2-work-with-normal-mac-osx-keyboard-shortcuts/
running "Add MacOS word navigation and delete shortcuts"
{
  # create needed value for shortcuts
  /usr/libexec/PlistBuddy -c "Add New\ Bookmarks:0:Keyboard\ Map dict" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add New\ Bookmarks:0:Keyboard\ Map:0x7f-0x100000 dict" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add New\ Bookmarks:0:Keyboard\ Map:0x7f-0x100000:Action integer" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add New\ Bookmarks:0:Keyboard\ Map:0x7f-0x100000:Text string" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add New\ Bookmarks:0:Keyboard\ Map:0x7f-0x80000 dict" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add New\ Bookmarks:0:Keyboard\ Map:0x7f-0x80000:Action integer" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add New\ Bookmarks:0:Keyboard\ Map:0x7f-0x80000:Text string" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add New\ Bookmarks:0:Keyboard\ Map:0xf702-0x280000 dict" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add New\ Bookmarks:0:Keyboard\ Map:0xf702-0x280000:Action integer" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add New\ Bookmarks:0:Keyboard\ Map:0xf702-0x280000:Text string" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add New\ Bookmarks:0:Keyboard\ Map:0xf702-0x300000 dict" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add New\ Bookmarks:0:Keyboard\ Map:0xf702-0x300000:Action integer" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add New\ Bookmarks:0:Keyboard\ Map:0xf702-0x300000:Text string" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add New\ Bookmarks:0:Keyboard\ Map:0xf703-0x280000 dict" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add New\ Bookmarks:0:Keyboard\ Map:0xf703-0x280000:Action integer" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add New\ Bookmarks:0:Keyboard\ Map:0xf703-0x280000:Text string" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add New\ Bookmarks:0:Keyboard\ Map:0xf703-0x300000 dict" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add New\ Bookmarks:0:Keyboard\ Map:0xf703-0x300000:Action integer" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Add New\ Bookmarks:0:Keyboard\ Map:0xf703-0x300000:Text string" ~/Library/Preferences/com.googlecode.iterm2.plist
  # Keyboard Shortcut: ⌘←Delete
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Keyboard\ Map:0x7f-0x100000:Action 1" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Keyboard\ Map:0x7f-0x100000:Text '0x15'" ~/Library/Preferences/com.googlecode.iterm2.plist
  # Keyboard Shortcut:⌥←Delete
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Keyboard\ Map:0x7f-0x80000:Action 11" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Keyboard\ Map:0x7f-0x80000:Text '0x1B 0x08'" ~/Library/Preferences/com.googlecode.iterm2.plist
  # Keyboard Shortcut: ⌥←
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Keyboard\ Map:0xf702-0x280000:Action 10" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Keyboard\ Map:0xf702-0x280000:Text 'b'" ~/Library/Preferences/com.googlecode.iterm2.plist
  # Keyboard Shortcut: ⌘←
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Keyboard\ Map:0xf702-0x300000:Action 10" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Keyboard\ Map:0xf702-0x300000:Text '[H'" ~/Library/Preferences/com.googlecode.iterm2.plist
  # Keyboard Shortcut: ⌥→
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Keyboard\ Map:0xf703-0x280000:Action 10" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Keyboard\ Map:0xf703-0x280000:Text 'f'" ~/Library/Preferences/com.googlecode.iterm2.plist
  # Keyboard Shortcut: ⌘→
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Keyboard\ Map:0xf703-0x300000:Action 10" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Keyboard\ Map:0xf703-0x300000:Text '[F'" ~/Library/Preferences/com.googlecode.iterm2.plist
} &> /dev/null;ok

running "Set dimming light to 0"
defaults write com.googlecode.iterm2 SplitPaneDimmingAmount -float 0;ok

running "Set minimum contrast to 0.225"
defaults write com.googlecode.iterm2 Minimum\ Contrast -float 0.225;ok

running "Set transparency to 0.110"
/usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Transparency 0.110" ~/Library/Preferences/com.googlecode.iterm2.plist;ok

running "Disable use of bright bold"
/usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Use\ Bright\ Bold false" ~/Library/Preferences/com.googlecode.iterm2.plist;ok

running "Installing the Solarized Dark theme for iTerm"
{
  # Add solarized colors
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Selected\ Text\ Color:Blue\ Component 0.56363654136657715" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Selected\ Text\ Color:Green\ Component 0.56485837697982788" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Selected\ Text\ Color:Red\ Component 0.50599193572998047" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Selection\ Color:Blue\ Component 0.19370138645172119" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Selection\ Color:Green\ Component 0.15575926005840302" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Selection\ Color:Red\ Component 0.0" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Foreground\ Color:Blue\ Component 0.51685798168182373" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Foreground\ Color:Green\ Component 0.50962930917739868" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Foreground\ Color:Red\ Component 0.44058024883270264" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Cursor\ Color:Blue\ Component 0.51685798168182373" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Cursor\ Color:Green\ Component 0.50962930917739868" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Cursor\ Color:Red\ Component 0.44058024883270264" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Cursor\ Text\ Color:Blue\ Component 0.19370138645172119" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Cursor\ Text\ Color:Green\ Component 0.15575926005840302" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Cursor\ Text\ Color:Red\ Component 0.0" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Bold\ Color:Blue\ Component 0.56363654136657715" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Bold\ Color:Green\ Component 0.56485837697982788" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Bold\ Color:Red\ Component 0.50599193572998047" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Background\ Color:Blue\ Component 0.15170273184776306" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Background\ Color:Green\ Component 0.11783610284328461" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Background\ Color:Red\ Component 0.0" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 0\ Color:Blue\ Component 0.19370138645172119" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 0\ Color:Green\ Component 0.15575926005840302" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 0\ Color:Red\ Component 0.0" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 1\ Color:Blue\ Component 0.14145714044570923" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 1\ Color:Green\ Component 0.10840655118227005" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 1\ Color:Red\ Component 0.81926977634429932" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 10\ Color:Blue\ Component 0.38298487663269043" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 10\ Color:Green\ Component 0.35665956139564514" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 10\ Color:Red\ Component 0.27671992778778076" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 11\ Color:Blue\ Component 0.43850564956665039" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 11\ Color:Green\ Component 0.40717673301696777" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 11\ Color:Red\ Component 0.32436618208885193" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 12\ Color:Blue\ Component 0.51685798168182373" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 12\ Color:Green\ Component 0.50962930917739868" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 12\ Color:Red\ Component 0.44058024883270264" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 13\ Color:Blue\ Component 0.72908437252044678" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 13\ Color:Green\ Component 0.33896297216415405" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 13\ Color:Red\ Component 0.34798634052276611" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 14\ Color:Blue\ Component 0.56363654136657715" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 14\ Color:Green\ Component 0.56485837697982788" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 14\ Color:Red\ Component 0.50599193572998047" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 15\ Color:Blue\ Component 0.86405980587005615" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 15\ Color:Green\ Component 0.95794391632080078" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 15\ Color:Red\ Component 0.98943418264389038" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 2\ Color:Blue\ Component 0.020208755508065224" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 2\ Color:Green\ Component 0.54115492105484009" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 2\ Color:Red\ Component 0.44977453351020813" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 3\ Color:Blue\ Component 0.023484811186790466" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 3\ Color:Green\ Component 0.46751424670219421" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 3\ Color:Red\ Component 0.64746475219726562" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 4\ Color:Blue\ Component 0.78231418132781982" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 4\ Color:Green\ Component 0.46265947818756104" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 4\ Color:Red\ Component 0.12754884362220764" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 5\ Color:Blue\ Component 0.43516635894775391" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 5\ Color:Green\ Component 0.10802463442087173" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 5\ Color:Red\ Component 0.77738940715789795" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 6\ Color:Blue\ Component 0.52502274513244629" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 6\ Color:Green\ Component 0.57082360982894897" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 6\ Color:Red\ Component 0.14679534733295441" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 7\ Color:Blue\ Component 0.79781103134155273" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 7\ Color:Green\ Component 0.89001238346099854" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 7\ Color:Red\ Component 0.91611063480377197" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 8\ Color:Blue\ Component 0.15170273184776306" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 8\ Color:Green\ Component 0.11783610284328461" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 8\ Color:Red\ Component 0.0" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 9\ Color:Blue\ Component 0.073530435562133789" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 9\ Color:Green\ Component 0.21325300633907318" ~/Library/Preferences/com.googlecode.iterm2.plist
  /usr/libexec/PlistBuddy -c "Set New\ Bookmarks:0:Ansi\ 9\ Color:Red\ Component 0.74176257848739624" ~/Library/Preferences/com.googlecode.iterm2.plist
} &> /dev/null
# this will open iTerm so it needs to be the last setting
# and even though we set the colors before, is always nice to have the file itself
if ! grep -F "Solarized Dark" ~/Library/Preferences/com.googlecode.iterm2.plist; then
  open "./configs/Solarized Dark.itermcolors"
fi > /dev/null 2>&1
ok

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
bot "Installing >Mendeley<"
###############################################################################
# checks if was already installed
firstinstall=`brew cask list | grep "mendeley-desktop" &> /dev/null ; echo $?`

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

# if first installation, opens
if [[ $firstinstall == 1 ]]; then
  open "/Applications/Mendeley Desktop.app"
fi
botdone

###############################################################################
bot "Installing >The Unarchiver<"
###############################################################################
require_cask the-unarchiver

# Work on El Capitan but for YOSEMITE it creates a "special file"
# somehwere the ~/Library/Containers folder
running "Set to extract archives to same folder as the archive"
defaults write cx.c3.theunarchiver extractionDestination -int 1;ok

running "Set the modification date of the created folder to the modification date of the archive file"
defaults write cx.c3.theunarchiver folderModifiedDate -int 2;ok

running "Delete archive after extraction"
defaults write cx.c3.theunarchiver deleteExtractedArchive -bool true;ok

running "Do not open folder afer extraction"
defaults write cx.c3.theunarchiver openExtractedFolder -bool false;ok

botdone


###############################################################################
bot "Installing >smcFanControl<"
###############################################################################
require_cask smcfancontrol

if [ ! -f ~/Library/Preferences/com.eidac.smcFanControl2.plist ]; then
  # opens and closes unarchiver untill the preferences are loaded
  open "/Applications/smcFanControl.app"
  # waiting for smcFanControl to create file
  while true; do
    sleep 1
    [ ! -f ~/Library/Preferences/com.eidac.smcFanControl2.plist ] || break
  done
  killall 'smcFanControl' > /dev/null 2>&1
fi

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
# re-sign the file to avoid firewall popup
sudo codesign --force --deep --sign - /Applications/Dropbox.app &> /dev/null

# always opens Dropbox since if it exists its silent
open "/Applications/Dropbox.app"
botdone


###############################################################################
bot "Installing remaining casks"
###############################################################################
# checks if  was already installed
firstinstall=`brew cask list | grep "spotify" &> /dev/null ; echo $?`
require_cask spotify
# if first installation, opens
if [[ $firstinstall == 1 ]]; then
  open "/Applications/Spotify.app"
fi

# checks if was already installed
firstinstall=`brew cask list | grep "cheatsheet" &> /dev/null ; echo $?`
require_cask cheatsheet
# if first installation, opens
if [[ $firstinstall == 1 ]]; then
  open "/Applications/CheatSheet.app"
fi

# checks if was already installed
if [ -f "$HOME/Library/PreferencePanes/AppTrap.prefPane" ]; then
  firstinstall=1
fi
require_cask apptrap
if [[ $firstinstall == 1 ]]; then
  open "$HOME/Library/PreferencePanes/AppTrap.prefPane"
fi

require_cask dockertoolbox
require_cask sqlitebrowser
require_cask vlc
# not working under El Capitan :(
#require_cask asepsis
require_cask basictex
require_cask skype
#require_cask kext-utility
require_cask teamviewer
require_cask gimp
require_cask alinof-timer

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

botdone


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
