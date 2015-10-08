#!/usr/bin/env bash

# include my library helpers for colorized echo and require_brew, etc
source ./lib.sh
# sourcing shellvars so we can get tools specific pre-loaded settings
source ~/.shellvars

# Ask for the administrator password upfront

bot "checking sudo state..."
if sudo grep -q "# %wheel\tALL=(ALL) NOPASSWD: ALL" "/etc/sudoers"; then

  promptSudo

  bot "Do you want me to setup this machine to allow you to run sudo without a password?\nPlease read here to see what I am doing:\nhttp://wiki.summercode.com/sudo_without_a_password_in_mac_os_x \n"

  read -r -p "Make sudo passwordless? [y|N] " response

  if [[ $response =~ (yes|y|Y) ]];then
      sed --version
      if [[ $? == 0 ]];then
          sudo sed -i 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers
      else
          sudo sed -i '' 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers
      fi
      sudo dscl . append /Groups/wheel GroupMembership $(whoami)
      bot "You can now run sudo commands without password!"
  fi
fi
ok

source ./brew.sh

################################################
bot "Standard System Changes"
################################################

# running "Set computer name (as done via System Preferences → Sharing)"
running "Set computer name to: jfloff"
sudo scutil --set ComputerName "jfloff"
sudo scutil --set HostName "jfloff"
sudo scutil --set LocalHostName "jfloff"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "jfloff"
dscacheutil -flushcache

#running "always boot in verbose mode (not OSX GUI mode)"
#sudo nvram boot-args="-v";ok

running "allow 'locate' command"
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist > /dev/null 2>&1;ok

running "Set standby delay to 24 hours (default is 1 hour)"
sudo pmset -a standbydelay 86400;ok

running "Disable the sound effects on boot"
sudo nvram SystemAudioVolume=" ";ok

###############################################################################
# SSD-specific tweaks                                                         #
###############################################################################

running "Disable local Time Machine snapshots"
sudo tmutil disablelocal;ok

running "Disable hibernation (speeds up entering sleep mode)"
sudo pmset -a hibernatemode 0;ok

running "Remove the sleep image file to save disk space"
sudo rm -rf /Private/var/vm/sleepimage;ok
running "Create a zero-byte file instead"
sudo touch /Private/var/vm/sleepimage;ok
running "…and make sure it can’t be rewritten"
sudo chflags uchg /Private/var/vm/sleepimage;ok

running "Disable the sudden motion sensor as it’s not useful for SSDs"
sudo pmset -a sms 0;ok

running "Restart automatically if the computer freezes"
sudo systemsetup -setrestartfreeze on;ok

#running "Never go into computer sleep mode"
#sudo systemsetup -setcomputersleep Off > /dev/null;ok

running "Check for software updates daily, not just once per week"
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1;ok

running "Disable automatic termination of inactive apps"
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true;ok

running "Disable the crash reporter"
defaults write com.apple.CrashReporter DialogType -string "none";ok


###############################################################################
bot "Configuring General System UI/UX..."
###############################################################################

# running "Disable smooth scrolling"
# (Uncomment if you’re on an older Mac that messes up the animation)
# defaults write NSGlobalDomain NSScrollAnimationEnabled -bool false;ok

running "Fix for the ancient UTF-8 bug in QuickLook (http://mths.be/bbo)"
# # Commented out, as this is known to cause problems in various Adobe apps :(
# # See https://github.com/mathiasbynens/dotfiles/issues/237
# echo "0x08000100:0" | sudo tee ~/.CFUserTextEncoding 2> /dev/null;ok
sudo sh -c 'echo "0x08000100:0" > ~/.CFUserTextEncoding' 2> /dev/null;ok

running "Stop iTunes from responding to the keyboard media keys"
launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2> /dev/null;ok

#running "Add a spacer to the left side of the Dock (where the applications are)"
#defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}';ok
#running "Add a spacer to the right side of the Dock (where the Trash is)"
#defaults write com.apple.dock persistent-others -array-add '{tile-data={}; tile-type="spacer-tile";}';ok

#running "Set a custom wallpaper image"
# `DefaultDesktop.jpg` is already a symlink, and
# all wallpapers are in `/Library/Desktop Pictures/`. The default is `Wave.jpg`.
#rm -rf ~/Library/Application Support/Dock/desktoppicture.db
#sudo rm -rf /System/Library/CoreServices/DefaultDesktop.jpg
#sudo ln -s ~/.dotfiles/img/wallpaper.jpg /System/Library/CoreServices/DefaultDesktop.jpg;ok

running "Menu bar: disable transparency"
defaults write NSGlobalDomain AppleEnableMenuBarTransparency -bool false;ok

running "Increase window resize speed for Cocoa applications"
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001;ok

running "Expand save panel by default"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true;ok

running "Expand print panel by default"
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true;ok

running "Save to disk (not to iCloud) by default"
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false;ok

running "Menu bar: hide the Time Machine, Volume, User, and Bluetooth icons"
for domain in ~/Library/Preferences/ByHost/com.apple.systemuiserver.*; do
  defaults write "${domain}" dontAutoLoad -array \
    "/System/Library/CoreServices/Menu Extras/TimeMachine.menu" \
    "/System/Library/CoreServices/Menu Extras/Volume.menu" \
    "/System/Library/CoreServices/Menu Extras/User.menu" \
    "/System/Library/CoreServices/Menu Extras/Bluetooth.menu"
done;
defaults write com.apple.systemuiserver menuExtras -array \
  "/System/Library/CoreServices/Menu Extras/AirPort.menu" \
  "/System/Library/CoreServices/Menu Extras/VPN.menu" \
  "/System/Library/CoreServices/Menu Extras/Battery.menu" \
  "/System/Library/CoreServices/Menu Extras/Clock.menu"
ok

running "Automatically quit printer app once the print jobs complete"
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true;ok

running "Remove duplicates in the “Open With” menu (also see 'lscleanup' alias)"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user;ok

running "Display ASCII control characters using caret notation in standard text views"
# Try e.g. `cd /tmp; unidecode "\x{0000}" > cc.txt; open -e cc.txt`
defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true;ok

running "Set Help Viewer windows to non-floating mode"
defaults write com.apple.helpviewer DevMode -bool true;ok

running "Reveal IP, hostname, OS, etc. when clicking clock in login window"
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName;ok

running "Disable Notification Center and remove the menu bar icon"
launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist > /dev/null 2>&1;ok

running "Disable smart quotes as they’re annoying when typing code"
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false;ok

running "Disable smart dashes as they’re annoying when typing code"
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false;ok

#running "Save screenshots to the desktop"
#defaults write com.apple.screencapture location -string "${HOME}/Desktop";ok

running "Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)"
defaults write com.apple.screencapture type -string "png";ok

running "Disable shadow in screenshots"
defaults write com.apple.screencapture disable-shadow -bool true;ok

#running "Enable subpixel font rendering on non-Apple LCDs"
#defaults write NSGlobalDomain AppleFontSmoothing -int 2;ok

#running "Enable HiDPI display modes (requires restart)"
#sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true;ok

################################################
bot "System Preferences > General"
################################################

# Set highlight color to green
defaults write NSGlobalDomain AppleHighlightColor -string "0.764700 0.976500 0.568600";ok

running "Set sidebar icon size to medium"
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2;ok

running "Always show scrollbars"
defaults write NSGlobalDomain AppleShowScrollBars -string "WhenScrolling";ok
# Possible values: `WhenScrolling`, `Automatic` and `Always`

running "Jump to the spot that's clicked on scollbar"
defaults write NSGlobalDomain AppleScrollerPagingBehavior -int 1;ok

running "Disable Resume system-wide"
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false;ok
# TODO: might want to enable this again and set specific apps that this works great for
# e.g. defaults write com.microsoft.word NSQuitAlwaysKeepsWindows -bool true

running "Set recent itens number to 5"
defaults write NSGlobalDomain NSRecentDocumentsLimit 5;ok


################################################
bot "System Preferences > Dock & Mission Control"
################################################

running "Wipe all (default) app icons from the Dock"
# # This is only really useful when setting up a new Mac, or if you don’t use
# # the Dock to launch apps.
defaults write com.apple.dock persistent-apps -array "";ok

running "Set the icon size of Dock items to 45 pixels"
defaults write com.apple.dock tilesize -int 45;ok

running "Disable Dock icon magnification"
defaults write com.apple.dock magnification -bool false;ok

running "Set Dock to appear on the right"
defaults write com.apple.dock orientation -string right

running "Change minimize/maximize window effect to genie"
defaults write com.apple.dock mineffect -string "genie";ok

running "Double-click a window's title bar to minimize"
defaults write NSGlobalDomain AppleMiniaturizeOnDoubleClick -bool true

running "Minimize windows into their application’s icon"
defaults write com.apple.dock minimize-to-application -bool true;ok

running "Animate opening applications from the Dock"
defaults write com.apple.dock launchanim -bool true;ok

running "Autohide Dock"
defaults write com.apple.dock autohide -bool true

running "Show indicator lights for open applications in the Dock"
defaults write com.apple.dock show-process-indicators -bool true;ok

running "Don’t automatically rearrange Spaces based on most recent use"
defaults write com.apple.dock mru-spaces -bool false;ok

running "Switch to space with open application"
defaults write com.apple.dock workspaces-auto-swoosh -bool true

running "Group windows by application in Mission Control"
# (i.e. use the old Exposé behavior instead)
defaults write com.apple.dock expose-group-by-app -bool true;ok

running "Disable Dashboard"
defaults write com.apple.dashboard mcx-disabled -bool true;ok

running "Don’t show Dashboard as a Space"
defaults write com.apple.dock dashboard-in-overlay -bool true;ok

# Hot Corners
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center

running "Top left screen corner → Mission Control"
defaults write com.apple.dock wvous-tl-corner -int 2
defaults write com.apple.dock wvous-tl-modifier -int 0;ok
running "Top right screen corner → Mission Control"
defaults write com.apple.dock wvous-tr-corner -int 2
defaults write com.apple.dock wvous-tr-modifier -int 0;ok
running "Bottom left screen corner → Desktop"
defaults write com.apple.dock wvous-bl-corner -int 4
defaults write com.apple.dock wvous-bl-modifier -int 0;ok
running "Bottom right screen corner → Desktop"
defaults write com.apple.dock wvous-br-corner -int 4
defaults write com.apple.dock wvous-br-modifier -int 0;ok

################################################
# Optional                                     #
################################################

running "Make Dock icons of hidden applications translucent"
defaults write com.apple.dock showhidden -bool true;ok

#running "Remove the auto-hiding Dock delay"
#defaults write com.apple.dock autohide-delay -float 0;ok

#running "Remove the animation when hiding/showing the Dock"
#defaults write com.apple.dock autohide-time-modifier -float 0;ok

#running "Make Dock more transparent"
#defaults write com.apple.dock hide-mirror -bool true;ok

running "Enable highlight hover effect for the grid view of a stack (Dock)"
defaults write com.apple.dock mouse-over-hilite-stack -bool true;ok

running "Enable spring loading for all Dock items"
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true;ok

running "Speed up Mission Control animations"
defaults write com.apple.dock expose-animation-duration -float 0.1;ok

running "Reset Launchpad, but keep the desktop wallpaper intact"
find "${HOME}/Library/Application Support/Dock" -name "*-*.db" -maxdepth 1 -delete;ok

################################################
bot "System Preferences > Language & Region"
################################################

# Set language and text formats
running "Set language and text formats (english/en)"
defaults write NSGlobalDomain AppleLanguages -array "en" "pt_PT"
defaults write NSGlobalDomain AppleLocale -string "en_US@currency=EUR"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
defaults write NSGlobalDomain AppleMetricUnits -bool true;ok

running "Set the timezone for Lisbon"
# see `sudo systemsetup -listtimezones` for other values
sudo systemsetup -settimezone "Europe/Lisbon" > /dev/null

running "Disable auto-correct"
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false;ok

################################################
bot "System Preferences > Security & Privacy"
################################################

running "Require password immediately after sleep or screen saver begins"
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0;ok

running "Disable the “Are you sure you want to open this application?” dialog"
defaults write com.apple.LaunchServices LSQuarantine -bool false;ok

running "Enable firewall ... better safe than sorry"
sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1;ok



###############################################################################
bot "System Preferences > Spotlight"
###############################################################################

running "Remove spotlight keyboard shortcut"
sudo defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "{enabled = 0; value = { parameters = (32, 49, 524288); type = 'standard'; }; }"

running "Hide Spotlight tray-icon (and subsequent helper)"
sudo chmod 600 /System/Library/CoreServices/Search.bundle/Contents/MacOS/Search;ok

running "Disable Spotlight indexing for any volume that gets mounted and has not yet been indexed"
# Use `sudo mdutil -i off "/Volumes/foo"` to stop indexing any volume.
sudo defaults write /.Spotlight-V100/VolumeConfiguration Exclusions -array "/Volumes";ok

running "Change indexing order and disable some file types from being indexed"
defaults write com.apple.spotlight orderedItems -array \
  '{"enabled" = 1;"name" = "APPLICATIONS";}' \
  '{"enabled" = 1;"name" = "SYSTEM_PREFS";}' \
  '{"enabled" = 1;"name" = "DIRECTORIES";}' \
  '{"enabled" = 1;"name" = "PDF";}' \
  '{"enabled" = 1;"name" = "FONTS";}' \
  '{"enabled" = 1;"name" = "DOCUMENTS";}' \
  '{"enabled" = 0;"name" = "MESSAGES";}' \
  '{"enabled" = 0;"name" = "CONTACT";}' \
  '{"enabled" = 1;"name" = "EVENT_TODO";}' \
  '{"enabled" = 1;"name" = "IMAGES";}' \
  '{"enabled" = 0;"name" = "BOOKMARKS";}' \
  '{"enabled" = 0;"name" = "MUSIC";}' \
  '{"enabled" = 1;"name" = "MOVIES";}' \
  '{"enabled" = 1;"name" = "PRESENTATIONS";}' \
  '{"enabled" = 1;"name" = "SPREADSHEETS";}' \
  '{"enabled" = 0;"name" = "SOURCE";}' \
  '{"enabled" = 0;"name" = "MENU_DEFINITION";}' \
  '{"enabled" = 0;"name" = "MENU_OTHER";}' \
  '{"enabled" = 0;"name" = "MENU_CONVERSION";}' \
  '{"enabled" = 0;"name" = "MENU_EXPRESSION";}' \
  '{"enabled" = 0;"name" = "MENU_WEBSEARCH";}' \
  '{"enabled" = 0;"name" = "MENU_SPOTLIGHT_SUGGESTIONS";}';ok

running "Load new settings before rebuilding the index"
killall mds > /dev/null 2>&1;ok

running "Make sure indexing is enabled for the main volume"
sudo mdutil -i on / > /dev/null;ok

#running "Rebuild the index from scratch"
sudo mdutil -E / > /dev/null;ok

################################################
bot "System Preferences > Keyboard"
################################################

running "Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)"
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3;ok

running "Use scroll gesture with the Ctrl (^) modifier key to zoom"
defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144;ok

running "Follow the keyboard focus while zoomed in"
defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true;ok

running "Disable press-and-hold for keys in favor of key repeat"
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false;ok

#running "Set a blazingly fast keyboard repeat rate"
#defaults write NSGlobalDomain KeyRepeat -int 0;

running "Turn off keyboard illumination when computer is not used for 5 minutes"
defaults write com.apple.BezelServices kDimTime -int 300;ok

################################################
bot "System Preferences > Trackpad"
################################################

#running "Trackpad: enable tap to click for this user and for the login screen"
#defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
#defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
#defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1;ok

running "Trackpad: map bottom right corner to right-click"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true;ok

running "Enable three finger tap (look up)"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerTapGesture -int 2;ok

running "Enable three finger drag"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true;ok

running "Disable “natural” (Lion-style) scrolling"
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false;ok

running "Zoom in or out"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadPinch -bool true;ok

running "Smart zoom, double-tap with two fingers"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadTwoFingerDoubleTapGesture -bool true;ok

running "Rotate"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRotate -bool true;ok

running "Swipe between pages with two fingers"
defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool true;ok

running "Swipe between full-screen apps with three fingers"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 2;ok

running "Show Notification Center"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadTwoFingerFromRightEdgeSwipeGesture -int 2;ok

# other gestures
running "Enabling other gestures"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerVertSwipeGesture -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerVertSwipeGesture -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerPinchGesture -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerHorizSwipeGesture -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFiveFingerPinchGesture -int 2;ok

running "Show Mission Control"
defaults write com.apple.dock showMissionControlGestureEnabled -bool true;ok

running "Disable Show Expose"
defaults write com.apple.dock showAppExposeGestureEnabled -bool false;ok

running "Disable the Launchpad gesture (pinch with thumb and three fingers)"
defaults write com.apple.dock showLaunchpadGestureEnabled -int 0;ok

running "Enable Show Desktop"
defaults write com.apple.dock showDesktopGestureEnabled -bool true;ok



################################################
bot "System Preferences > Sound"
################################################

#running "Increase sound quality for Bluetooth headphones/headsets"
#defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40;ok

################################################
bot "Finder Preferences"
################################################

running "Show icons for hard drives, servers, and removable media on the desktop"
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
#defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true;ok

#running "Allow quitting via ⌘ + Q; doing so will also hide desktop icons"
#defaults write com.apple.finder QuitMenuItem -bool true;ok

#running "Disable window animations and Get Info animations"
#defaults write com.apple.finder DisableAllAnimations -bool true;ok

running "Set Desktop as the default location for new Finder windows"
# For other paths, use `PfLo` and `file:///full/path/here/`
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/";ok

#running "Show hidden files by default"
#defaults write com.apple.finder AppleShowAllFiles -bool true;ok

running "Show all filename extensions"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true;ok

running "Show status bar"
defaults write com.apple.finder ShowStatusBar -bool true;ok

running "Show path bar"
defaults write com.apple.finder ShowPathbar -bool true;ok

running "Allow text selection in Quick Look"
defaults write com.apple.finder QLEnableTextSelection -bool true;ok

running "Display full POSIX path as Finder window title"
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true;ok

running "When performing a search, search the current folder by default"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf";ok

running "Disable the warning when changing a file extension"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false;ok

running "Enable spring loading for directories"
defaults write NSGlobalDomain com.apple.springing.enabled -bool true;ok

running "Remove the spring loading delay for directories"
defaults write NSGlobalDomain com.apple.springing.delay -float 0;ok

running "Avoid creating .DS_Store files on network volumes"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true;ok

running "Disable disk image verification"
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true;ok

running "Automatically open a new Finder window when a volume is mounted"
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true;ok

running "Use list view in all Finder windows by default"
# Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv";ok

#running "Disable the warning before emptying the Trash"
#defaults write com.apple.finder WarnOnEmptyTrash -bool false;ok

running "Empty Trash securely by default"
defaults write com.apple.finder EmptyTrashSecurely -bool true;ok

running "Enable AirDrop over Ethernet and on unsupported Macs running Lion"
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true;ok

running "Show the ~/Library folder"
chflags nohidden ~/Library;ok

running "Expand the following File Info panes: “General”, “Open with”, and “Sharing & Permissions”"
defaults write com.apple.finder FXInfoPanesExpanded -dict \
  General -bool true \
  OpenWith -bool true \
  Privileges -bool true;ok

# running "Enable the MacBook Air SuperDrive on any Mac"
# sudo nvram boot-args="mbasd=1";ok

running "Remove Dropbox’s green checkmark icons in Finder"
file=/Applications/Dropbox.app/Contents/Resources/emblem-dropbox-uptodate.icns
[ -e "${file}" ] && mv -f "${file}" "${file}.bak";ok


###############################################################################
bot "Calendar"
###############################################################################

running "Show week numbers (10.8 only)"
defaults write com.apple.iCal "Show Week Numbers" -bool true;ok

running "Show 7 days"
defaults write com.apple.iCal "n days of week" -int 7;ok

running "Week starts on monday"
defaults write com.apple.iCal "first day of week" -int 1;ok

running "Show event times"
defaults write com.apple.iCal "Show time in Month View" -bool true;ok


###############################################################################
bot "Terminal"
###############################################################################

#running "Enable “focus follows mouse” for Terminal.app and all X11 apps"
# i.e. hover over a window and start typing in it without clicking first
#defaults write com.apple.terminal FocusFollowsMouse -bool true
#defaults write org.x.X11 wm_ffm -bool true;ok

running "Only use UTF-8 in Terminal.app"
defaults write com.apple.terminal StringEncodings -array 4;ok

running "Set the 'Pro' as the default"
defaults write com.apple.Terminal "Startup Window Settings" -string "Pro"
defaults write com.apple.Terminal "Default Window Settings" -string "Pro";ok


###############################################################################
bot "iTerm2"
###############################################################################

running "Installing the Solarized Dark theme for iTerm (opening file)"
open "./configs/Solarized Dark.itermcolors";ok

running "Copying pre-set definitions"
yes | cp -rf ./configs/iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist

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


###############################################################################
bot "Time Machine"
###############################################################################

running "Prevent Time Machine from prompting to use new hard drives as backup volume"
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true;ok

running "Disable local Time Machine backups"
hash tmutil &> /dev/null && sudo tmutil disablelocal;ok

###############################################################################
bot "Activity Monitor"
###############################################################################

running "Show the main window when launching Activity Monitor"
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true;ok

running "Visualize CPU usage in the Activity Monitor Dock icon"
defaults write com.apple.ActivityMonitor IconType -int 5;ok

running "Show all processes in Activity Monitor"
defaults write com.apple.ActivityMonitor ShowCategory -int 0;ok

running "Sort Activity Monitor results by CPU usage"
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0;ok


###############################################################################
bot "TextEdit"
###############################################################################

#running "Enable the debug menu in Address Book"
#defaults write com.apple.addressbook ABShowDebugMenu -bool true;ok

#running "Enable Dashboard dev mode (allows keeping widgets on the desktop)"
#defaults write com.apple.dashboard devmode -bool true;ok

running "Use plain text mode for new TextEdit documents"
defaults write com.apple.TextEdit RichText -int 0;ok

running "Open and save files as UTF-8 in TextEdit"
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4;ok

#running "Enable the debug menu in Disk Utility"
#defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
#defaults write com.apple.DiskUtility advanced-image-options -bool true;ok

###############################################################################
bot "Mac App Store"
###############################################################################

#running "Enable the WebKit Developer Tools in the Mac App Store"
#defaults write com.apple.appstore WebKitDeveloperExtras -bool true;ok

#running "Enable Debug Menu in the Mac App Store"
#defaults write com.apple.appstore ShowDebugMenu -bool true;ok

###############################################################################
bot "Google Chrome"
###############################################################################

running "Allow installing user scripts via GitHub Gist or Userscripts.org"
defaults write com.google.Chrome ExtensionInstallSources -array "https://gist.githubusercontent.com/" "http://userscripts.org/*"

running "Use the system-native print preview dialog"
defaults write com.google.Chrome DisablePrintPreview -bool true;ok

running "Expand the print dialog by default"
defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true;ok

###############################################################################
bot "Atom"
###############################################################################

# emulate the 'install shell commands' from inside atom
running "Installing Atom Shell Tools"
sudo rm /usr/local/bin/apm
ln -s /Applications/Atom.app/Contents/Resources/app/apm/node_modules/.bin/apm /usr/local/bin/apm
sudo rm /usr/local/bin/atom
ln -s /Applications/Atom.app/Contents/Resources/app/atom.sh /usr/local/bin/atom;ok

running "Installing packages"
# strip packages of versions
sed -i 's/@.*//' ./configs/atom-packages.txt
apm install --packages-file ./configs/atom-packages.txt;ok
# require_apm linter
# require_apm linter-eslint
# require_apm atom-beautify

###############################################################################
bot "Transmission"
###############################################################################

running "Use `~/Documents/Torrents` to store incomplete downloads"
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

###############################################################################
# Kill affected applications                                                  #
###############################################################################
bot "OK. Note that some of these changes require a logout/restart to take effect. Killing affected applications (so they can reboot)...."
for app in "Activity Monitor" "Address Book" "Calendar" "Contacts" "cfprefsd" \
  "Dock" "Finder" "Mail" "Messages" "Safari" "SystemUIServer" \
  "iCal" "Terminal" "Transmission" "Atom"; do
  killall "${app}" > /dev/null 2>&1
done
