#!/bin/bash

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# Source global definitions
if [ -f /etc/bashrc ]; then
	source /etc/bashrc
fi
# .bashrc

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

if command -v starship 1> /dev/null 2> /dev/null; then
    eval "$(starship init bash)"
fi

shopt -s globstar
shopt -s dotglob
shopt -s histappend
shopt -s checkwinsize
shopt -s histappend

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

bind '"\ee": edit-and-execute-command' # Alt-e   : Edit command prompt with $EDITOR

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

HISTFILE="$XDG_CACHE_HOME/bash/history"
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=2000

source "$XDG_CONFIG_HOME/zsh/.zshenv"
source "$XDG_CONFIG_HOME/zsh/.aliases"
