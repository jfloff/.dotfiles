#!/usr/bin/env bash

###########################
# This script bootstrap the .dotfiles in a system without git
###########################

# check if there is a clone of .dotfiles already running
if [[ ! -e ~/.dotfiles ]]; then
  # doesn't exist
  # install command line tools
  xcode-select --install
  # clone repo
  git clone --recurse-submodules https://github.com/jfloff/.dotfiles ~/.dotfiles
fi

# already exists run install script
pushd ~/.dotfiles/ > /dev/null 2>&1
./install.sh
popd > /dev/null 2>&1
