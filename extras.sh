#!/usr/bin/env bash

# make a downlaods directory
if [[ ! -e ./downloads ]]; then
    mkdir ./downloads
fi

###############################################################################
bot "Installing Alfred"
###############################################################################
pushd .downloads > /dev/null 2>&1
wget_download https://www.dropbox.com/s/b8bwzhl7trj9rxx/alfred-2.8_414.zip?dl=0
unzip alfred-2.8_414.zip -d alfred-2.8_414
open alfred-2.8_414
popd > /dev/null 2>&1

question "Is Alfred correctly installed? [y|N]" response
if [[ $response =~ ^(yes|y|Y) ]];then
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

###############################################################################
bot "Installing Texpad"
###############################################################################
pushd .downloads > /dev/null 2>&1
wget_download https://www.dropbox.com/s/t85ydbgero0p7ge/texpad-1716.zip?dl=0
unzip texpad-1716.zip.zip -d texpad-1716.zip
open texpad-1716.zip
popd > /dev/null 2>&1

###############################################################################
bot "Downloading custom link software"
###############################################################################
wget_download http://cdn.sa.services.tomtom.com/static/sa/Mac/MyDriveConnect.dmg
wget_download https://www.dropbox.com/s/1pp7ai6q9dng33d/tuxera-nfts-2015.zip?dl=0
