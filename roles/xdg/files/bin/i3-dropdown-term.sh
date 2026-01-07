#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# FILTER='instance="kitty" class="^dropdown-term$"'
FILTER='instance="st-256color|kitty|dropdown-term" class="^dropdown-term$"'

# Detect sway (Wayland) vs i3 (X11)
if [ -n "$SWAYSOCK" ] || [ -n "$WAYLAND_DISPLAY" ]; then
    FILTER='app_id="^dropdown-term$"'
    MSG="swaymsg"
else
    FILTER='instance="st-256color|kitty|dropdown-term" class="^dropdown-term$"'
    MSG="i3-msg"
fi

term() {
    local cmd
    #cmd='exec tmux new-session -A -s dropdown-term -c "${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles"'
    cmd='exec tmuxp load -y home'

    if test "$1" = kitty; then
        exec kitty --name "kitty" --class "dropdown-term" --override 'initial_window_width=150c' --override 'initial_window_height=40c' -e bash -c "$cmd"
    else
        exec st -c "dropdown-term" -g 200x60 -e bash -c "$cmd"
    fi
}

$MSG "[ $FILTER ] scratchpad show, move position center" ||
    $MSG "[ $FILTER ] move workspace current, focus" ||
    term "$@"

