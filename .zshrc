# Path to your oh-my-zsh configuration.
export ZSH=$HOME/.dotfiles/oh-my-zsh

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

# Which plugins would you like to load? (plugins can be found in ~/.dotfiles/oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)

source $ZSH/oh-my-zsh.sh

# Using hub feels best when it's aliased as git.
# Your normal git commands will all work, hub merely adds some sugar.
eval "$(hub alias -s)"

# load antigen
source $HOME/.dotfiles/antigen/antigen.zsh

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle atom
antigen bundle bundler
antigen bundle common-aliases
antigen bundle git
antigen bundle git-extras
antigen bundle github
antigen bundle httpie
antigen bundle jsontools
antigen bundle last-working-dir
antigen bundle osx
antigen bundle wd
antigen bundle colored-man
antigen bundle colorize
antigen bundle cp
antigen bundle extract
antigen bundle brew
antigen bundle brew-cask
antigen bundle unixorn/autoupdate-antigen.zshplugin
antigen bundle command-not-found
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-completions src
antigen bundle zsh-users/zsh-history-substring-search

# Load the theme.
antigen theme pygmalion

# Tell antigen that you're done.
antigen apply

# dunno
cd $HOME

# run fortune on new terminal :)
fortune
