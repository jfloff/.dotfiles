#!/usr/bin/env bash

###########################
# This script bootstrap the .dotfiles in a system without git
###########################

# check if there is a clone of .dotfiles already running
if [[ ! -e ~/.dotfiles ]]; then
  # install command line tools so we have git
  #run in background so we can catch the PID
  xcode-select --install &
  # wait for xcode-select to finish
  wait $!
  # clone repo
  git clone --recurse-submodules https://github.com/jfloff/.dotfiles ~/.dotfiles
fi

# already exists run install script
pushd ~/.dotfiles/ > /dev/null 2>&1
./install.sh
popd > /dev/null 2>&1
