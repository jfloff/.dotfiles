#!/usr/bin/env bash

# make a downlaods directory
if [[ ! -e ./downloads ]]; then
    mkdir ./downloads
fi

###############################################################################
bot "Setting up >Alfred<"
###############################################################################
running "Installing Alfred"
pushd ./downloads > /dev/null 2>&1
download https://www.dropbox.com/s/b8bwzhl7trj9rxx/alfred-2.8_414.zip
unzip -qof alfred-2.8_414.zip
open alfred-2.8_414
popd > /dev/null 2>&1
ok

question "Is Alfred correctly installed? [y|N]" response
if [[ $response =~ ^(yes|y|Y) ]];then
  running "symlinking preferences"; filler
  pushd ~/Library/Application\ Support/Alfred\ 2/ > /dev/null 2>&1
  symlinkifne Alfred.alfredpreferences
  popd > /dev/null 2>&1
  ok

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

# texpad
download https://www.dropbox.com/s/t85ydbgero0p7ge/texpad-1716.zip
unzip -qof texpad-1716.zip
# tuxera ntfs
download https://www.dropbox.com/s/1pp7ai6q9dng33d/tuxera-nfts-2015.zip
unzip -qof texpad-1716.zip
# ms office
download https://www.dropbox.com/s/zr8fzj6ppp40ci9/msoffice-2016-15.14.0.zip
unzip -qof msoffice-2016-15.14.0.zip
# tom tom GPS
download http://cdn.sa.services.tomtom.com/static/sa/Mac/MyDriveConnect.dmg
# open this dir in finder so we can install
open .
popd > /dev/null 2>&1
botdone
