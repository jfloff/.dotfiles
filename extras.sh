#!/usr/bin/env bash

# Keep-alive: update existing sudo time stamp until the script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# make a downloads directory
if [[ ! -e ./downloads ]]; then
    mkdir ./downloads
fi

###############################################################################
bot "Setting up >Alfred<"
###############################################################################
running "Installing Alfred"; filler
pushd ./downloads > /dev/null 2>&1
download https://www.dropbox.com/s/b8bwzhl7trj9rxx/alfred-2.8_414.zip
unzip -qo alfred-2.8_414.zip
open alfred-2.8_414
popd > /dev/null 2>&1
ok

question "Is Alfred correctly installed? [y|N]" response
if [[ $response =~ ^(yes|y|Y) ]];then
  # after installation Application Support folder is not created
  if [[ ! -e ~/Library/Application\ Support/Alfred\ 2/ ]]; then
      mkdir ~/Library/Application\ Support/Alfred\ 2/
  fi

  running "symlinking preferences"; filler
  pushd ~/Library/Application\ Support/Alfred\ 2/ > /dev/null 2>&1
  symlinkifne Alfred.alfredpreferences
  popd > /dev/null 2>&1

  # running "Installing Workflows"
  # caffeinate
  #required_alfred_workflow https://github.com/packal/repository/raw/master/com.shawn.patrick.rice.caffeinate.control/caffeinate_control.alfredworkflow
  # convert
  # required_alfred_workflow https://github.com/packal/repository/raw/master/net.deanishe.alfred-convert/convert-2.2.alfredworkflow
  # packal updater
  # required_alfred_workflow https://github.com/packal/repository/raw/master/com.packal/packal.alfredworkflow
  # terminalfinder
  # required_alfred_workflow https://github.com/LeEnno/alfred-terminalfinder/raw/master/TerminalFinder.alfredworkflow
  # stack overflow
  # required_alfred_workflow https://github.com/packal/repository/raw/master/stack_overflow/stackoverflow.alfredworkflow
  # ok;
fi
botdone


###############################################################################
bot "Downloading custom link software"
###############################################################################
pushd ./downloads > /dev/null 2>&1
download https://www.dropbox.com/s/t85ydbgero0p7ge/texpad-1716.zip
download https://www.dropbox.com/s/1pp7ai6q9dng33d/tuxera-nfts-2015.zip
# download https://www.dropbox.com/s/zr8fzj6ppp40ci9/msoffice-2016-15.14.0.zip
# tom tom GPS
download http://cdn.sa.services.tomtom.com/static/sa/Mac/MyDriveConnect.dmg

# unzips all and opens dir in finder so we can install
unzip -qo texpad-1716.zip
unzip -qo tuxera-nfts-2015.zip
# unzip -qo msoffice-2016-15.14.0.zip
open .
popd > /dev/null 2>&1
botdone
