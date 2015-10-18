#!/usr/bin/env bash

###############################################################################
bot "Setting up >Alfred 2<"
###############################################################################
running "Installing Alfred 2"; filler
pushd ~/Downloads > /dev/null 2>&1
download https://www.dropbox.com/s/b8bwzhl7trj9rxx/alfred-2.8_414.zip
open .
popd > /dev/null 2>&1

question "Is Alfred correctly installed? [y|N]" response
if [[ $response =~ ^(yes|y|Y) ]];then
  alfpath=`whichapp 'Alfred 2'`
  if [ $? == 1 ]; then
    msg "Alfred 2 is not yet installed! Skipping setting preferences. (Run me again after you've installed Alfred 2)"
  else
    # kills alfred if was open so we can safely link preferences
    killall 'Alfred 2' > /dev/null 2>&1

    running "Symlinking preferences"
    if [[ ! -e ~/Library/Application\ Support/Alfred\ 2/ ]]; then
        mkdir ~/Library/Application\ Support/Alfred\ 2/
    fi
    pushd ~/Library/Application\ Support/Alfred\ 2/ > /dev/null 2>&1
    symlinkifne Alfred.alfredpreferences
    popd > /dev/null 2>&1

    running "Switching local settings to saved ones";

    # mini-script so we can link our local-preferences to the ones created by Alfred
    pushd Alfred.alfredpreferences/preferences/local/ > /dev/null 2>&1
    inumber=`stat -c '%i' ../local-preferences`
    # searches for any file in this dir (assuming any file here is already linked)
    search=`find . -inum $inumber 2> /dev/null`
    if [[ -z $search ]] ; then
      # gets last directory created so we check if Alfed has alrerady created the directory or not
      lastdir=`ls -td -- ./*/ 2> /dev/null | head -n1 | cut -d'/' -f2` > /dev/null 2>&1
      if [[ -z $lastdir ]]; then
        # Since no folder founds, forces Alfred to open so the dir is created
        open "$alfpath"
        # waiting for Alfred to create the folder
        while true; do
          sleep 1
          lastdir=`ls -td -- ./*/ 2> /dev/null | head -n1 | cut -d'/' -f2` > /dev/null 2>&1
          [[ -z $lastdir ]] || break
        done
        # kills alfred after so we can safely link local preferences
        killall 'Alfred 2'
      fi
      # removes created Alfred directory
      rm -rf "$lastdir"
      # hardlinks local-preferences folder to name of created by Alfred
      # I know this is "dangerous" but we have the directory backed up by git
      # and yes softlinks didn't work :(
      hln ../local-preferences "$lastdir"
    fi
    popd > /dev/null 2>&1

    ok;
  fi
fi
botdone

exit
###############################################################################
bot "Downloading custom link software"
###############################################################################
pushd ~/Downloads > /dev/null 2>&1
download https://www.dropbox.com/s/t85ydbgero0p7ge/texpad-1716.zip
download https://www.dropbox.com/s/1pp7ai6q9dng33d/tuxera-nfts-2015.zip
download https://www.dropbox.com/s/zr8fzj6ppp40ci9/msoffice-2016-15.14.0.zip
download https://www.dropbox.com/s/w7d6mqenbg79lai/shapes-4.34.zip?dl=0
# tom tom GPS
# download http://cdn.sa.services.tomtom.com/static/sa/Mac/MyDriveConnect.dmg

# unzips all and opens dir in finder so we can install
open .
popd > /dev/null 2>&1
botdone
