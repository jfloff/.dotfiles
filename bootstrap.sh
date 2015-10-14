#!/usr/bin/env bash

###########################
# This script bootstrap the .dotfiles in a system without git
###########################

# check if there is a clone of .dotfiles already running
if [[ ! -e ~/.dotfiles ]]; then
  # install command line tools so we have git
  # loops while we don't have the tools installed
  while true; do
    xcode-select --install > /dev/null 2>&1
    sleep 5
    xcode-select -p > /dev/null 2>&1
    [ $? == 2 ] || break
  done
  # clone repo
  git clone --recurse-submodules https://github.com/jfloff/.dotfiles ~/.dotfiles > /dev/null 2>&1
fi

# already exists run install script
pushd ~/.dotfiles/ > /dev/null 2>&1
./install.sh
popd > /dev/null 2>&1
