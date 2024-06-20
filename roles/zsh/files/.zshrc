# Add completions directory

# NOTE(d.paro): /usr/share/zsh/vendor-completions contains docker completions
fpath=(/usr/share/zsh/vendor-completions $fpath)

KEYTIMEOUT=20
HISTFILE="$XDG_CACHE_HOME/zsh/history"
SAVEHIST=16384
HISTSIZE=32768
HISTTIMEFORMAT="[%F %T] "

extract() {
for archive in "$@"; do
    if [ -f "$archive" ]; then
        case $archive in
        *.tar.bz2) tar xvjf $archive ;;
        *.tar.gz) tar xvzf $archive ;;
        *.bz2) bunzip2 $archive ;;
        *.rar) rar x $archive ;;
        *.gz) gunzip $archive ;;
        *.tar) tar xvf $archive ;;
        *.tbz2) tar xvjf $archive ;;
        *.tgz) tar xvzf $archive ;;
        *.zip) unzip $archive ;;
        *.Z) uncompress $archive ;;
        *.7z) 7z x $archive ;;
        *) echo "don't know how to extract '$archive'..." ;;
        esac
    else
        echo "'$archive' is not a valid file!"
    fi
done
}

# Delete word on forward slash boundaries, and saner word delimiters in general
autoload -U select-word-style
WORDCHARS=':#$%^-_.'
select-word-style normal      # Word characters are alphanumerics plus $WORDCHARS


# Emacs style keybinds
bindkey -e

# Edit the current command line in $EDITOR (C-x C-e)
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line


# [Home] bind
if [[ -n "$TMUX" ]] && [[ "${terminfo[khome]}" != "" ]]; then
    bindkey "${terminfo[khome]}" beginning-of-line
else
    bindkey "^[[H" beginning-of-line
fi

# [End] bind
if [[ -n "$TMUX" ]] && [[ "${terminfo[kend]}" != "" ]]; then
    bindkey "${terminfo[kend]}"  end-of-line
else
    bindkey "^[[F"  end-of-line
fi


function zle-clipboard-paste {
  if ((REGION_ACTIVE)); then
    zle kill-region
  fi
  LBUFFER+="$(paste)"
}
zle -N zle-clipboard-paste


## X11 clipboard
x-copy-region-as-kill () {
  zle copy-region-as-kill
  print -rn $CUTBUFFER | copy
}
zle -N x-copy-region-as-kill
bindkey -e '\ew' x-copy-region-as-kill

# Bind CTRL+{Left, Right} Keys
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey "^[[3~"   delete-char
bindkey "^?"      backward-delete-char
bindkey '^H'      backward-delete-word
bindkey '^V'      zle-clipboard-paste
bindkey '^Z'      undo
# Ctrl+Shift+Z
bindkey '^[[122;6u'      redo


# Alt arrow keys: Run an innocuous command: eg beep
bindkey "^[[1;3A" beep
bindkey "^[[1;3B" beep
bindkey "^[[1;3C" beep
bindkey "^[[1;3D" beep
bindkey "^[[5~" beep      # Unbind page up
bindkey "^[[6~" beep      # Unbind PageDown


# Some additional keybinds
# bindkey -s "^P" 'nvim +Files ./\n'
# bindkey -s '^[OS' '[ -n "$TMUX" ] || run kitty -- tmux\n'

# By calling export zsh before the instan-prompt,
# and by later calling the direnv hook we avoid
# the instant-prompt complaining when inside tmux sessions
if command -v direnv 1> /dev/null 2> /dev/null; then
    eval "$(direnv export zsh)"
fi

if command -v starship 1> /dev/null 2> /dev/null; then
    eval "$(starship init zsh)"
fi


# This export makes sure that direnv does not output any stdout
# export DIRENV_LOG_FORMAT=""
if command -v direnv 1> /dev/null 2> /dev/null; then
    eval "$(direnv hook zsh)"
fi

setopt autocontinue
setopt globdots
setopt interactivecomments    # Bash style `#` comments in command line
setopt histignorespace        # If command starts with a space, do not save it in history (ie run a private command)

setopt EXTENDED_HISTORY       # record timestamp of command in HISTFILE
setopt HIST_EXPIRE_DUPS_FIRST # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt HIST_IGNORE_DUPS       # ignore duplicated commands history list
setopt HIST_IGNORE_SPACE      # ignore commands that start with space
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY            # show command with history expansion to user before running it
#setopt SHARE_HISTORY          # share command history data between zsh sessions. Completions are shared btween different zsh shells without requiring restarting the shell.
setopt INC_APPEND_HISTORY   # append history and not share it between terminals (unlike share_history)

# Make the tab completion matcher case insensitive
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

### Fish-like menulist
zmodload zsh/complist
setopt automenu
##
# When prompting for menu on multiple candidates, the first candidate is completed regardless if the user cycled the list
# Leave this off to obtain a fish-like behaviour.
##
#  setopt menucomplete
zstyle ':completion:*' menu select=1
bindkey -M menuselect '^[[Z' reverse-menu-complete         # Shift tab in menu-list to go to previous element in the list

autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"

autoload bashcompinit && bashcompinit

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"


## Setup LS_COLORS environment variable
if [ -x /usr/bin/dircolors ]; then
    if test -r ~/.dircolors; then
        eval "$(dircolors -b ~/.dircolors)"
    else
        eval "$(dircolors -b)"
    fi
fi


## Conda initialization
if [ -d "$XDG_DATA_HOME/anaconda3/bin" ]; then
    # >>> conda initialize >>>
    # !! Contents within this block are managed by 'conda init' !!
    __conda_setup="$("$XDG_DATA_HOME/anaconda3/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "$XDG_DATA_HOME/anaconda3/etc/profile.d/conda.sh" ]; then
            . "$XDG_DATA_HOME/anaconda3/etc/profile.d/conda.sh"
        else
            export PATH="$XDG_DATA_HOME/anaconda3/bin:$PATH"
        fi
    fi
    unset __conda_setup
    # <<< conda initialize <<<
fi

## NVM
[ -s "${NVM_DIR:-"$HOME/.mvn"}/nvm.sh" ] && source "${NVM_DIR:-"$HOME/.mvn"}/nvm.sh"
[ -s "${NVM_DIR:-"$HOME/.mvn"}/nvm.sh" ] && source "${NVM_DIR:-"$HOME/.mvn"}/bash_completion"


## TERMINATE: Setup the aliases that we need
source "$ZDOTDIR/.aliases"

if [ -f "$ZDOTDIR/.localrc" ]; then
    source "$ZDOTDIR/.localrc"
fi


# FZF Auto-completion and keybinds
# ---------------
[[ $- == *i* ]] && source "$HOME/opt/fzf/shell/completion.zsh" 2> /dev/null  # Ebabke cinoketuib ibky uf shell is interactive
source "$HOME/opt/fzf/shell/key-bindings.zsh"


source "$XDG_CONFIG_HOME/zsh/command-not-found.zsh"


source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_STYLES[comment]=fg=yellow,bold


if command -v krabby 1> /dev/null 2> /dev/null; then
    krabby random 1-3   # https://github.com/yannjor/krabby: cargo install krabby
elif command -v pokemon-colorscripts 1> /dev/null 2> /dev/null; then
    pokemon-colorscripts -r 1-3 # https://gitlab.com/phoneybadger/pokemon-colorscripts#similar-projects
fi


[[ ! -r "${OPAMROOT:-$HOME/.opam}/opam-init/init.zsh" ]] \
    || source "${OPAMROOT:-$HOME/.opam}/opam-init/init.zsh"  > /dev/null 2> /dev/null


# AWS Cli completion
if builtin type aws 1>/dev/null 2>/dev/null; then
    complete -C '/usr/local/bin/aws_completer' aws
fi

if builtin type kubectl 1>/dev/null 2>/dev/null; then
    source <(kubectl completion zsh)
fi


if builtin type flutter 1>/dev/null 2>/dev/null; then
    source <(flutter zsh-completion)
fi

if builtin type terraform 1> /dev/null 2> /dev/null; then
    complete -o nospace -C /usr/bin/terraform terraform
fi

