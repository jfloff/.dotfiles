# Set to this to use case-sensitive completion
export CASE_SENSITIVE="true"

# Set CLICOLOR if you want Ansi Colors in iTerm2
export CLICOLOR=1

# Set colors to match iTerm2 Terminal Colors
export TERM=xterm-256color

# Comment this out to disable weekly auto-update checks
# export DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# export DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# export DISABLE_AUTO_TITLE="true"

# Not needed since we ae using antigen
# Path to your oh-my-zsh configuration.
# export ZSH=$HOME/.dotfiles/oh-my-zsh
# Which plugins would you like to load? (plugins can be found in ~/.dotfiles/oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
# source $ZSH/oh-my-zsh.sh

# Using hub feels best when it's aliased as git.
# Your normal git commands will all work, hub merely adds some sugar.
eval "$(hub alias -s)"

# load antigen
source $HOME/.dotfiles/antigen/antigen.zsh

# # Load the oh-my-zsh's library.
antigen use oh-my-zsh

# brew coreutils - due to bug this path has to come AFTER the oh-my-zsh
export PATH=/usr/local/opt/coreutils/libexec/gnubin:$PATH
export MANPATH=/usr/local/opt/coreutils/libexec/gnuman:$MANPATH

# Bundles from the default repo (robbyrussell's oh-my-zsh).
# https://github.com/robbyrussell/oh-my-zsh/wiki/Plugins-Overview
# https://github.com/robbyrussell/oh-my-zsh/wiki/Plugins
# https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins
antigen bundle colored-man-pages
antigen bundle colorize
antigen bundle command-not-found
antigen bundle copydir
antigen bundle cp
antigen bundle dirpersist
antigen bundle per-directory-history
antigen bundle wd
antigen bundle docker
antigen bundle git-extras
antigen bundle git-flow
antigen bundle github
antigen bundle gnu-utils
antigen bundle brew
antigen bundle brew-cask
antigen bundle osx
antigen bundle common-aliases
antigen bundle web-search
antigen bundle extract
antigen bundle unixorn/autoupdate-antigen.zshplugin
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-completions src
antigen bundle zsh-users/zsh-history-substring-search

# Load the theme.
antigen theme pygmalion

# Tell antigen that you're done.
antigen apply

# run fortune on new terminal :)
fortune
