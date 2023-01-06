KEYTIMEOUT=20
HISTFILE="$XDG_CACHE_HOME/zsh/history"
SAVEHIST=16384
HISTSIZE=32768
HISTTIMEFORMAT="[%F %T] "


# Delete word on forward slash boundaries, and saner word delimiters in general
autoload -U select-word-style
WORDCHARS=':#$%^-_.'
select-word-style normal      # Word characters are alphanumerics plus $WORDCHARS


# Emacs style keybinds
bindkey -e

function zle-clipboard-paste {
  if ((REGION_ACTIVE)); then
    zle kill-region
  fi
  LBUFFER+="$(xclip -selection clipboard -out)"
}
zle -N zle-clipboard-paste


## X11 clipboard
x-copy-region-as-kill () {
  zle copy-region-as-kill
  print -rn $CUTBUFFER | xclip -selection clipboard
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
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'

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
