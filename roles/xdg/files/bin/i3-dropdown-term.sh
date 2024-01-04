#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# FILTER='instance="kitty" class="^dropdown-term$"'
FILTER='instance="st-256color|kitty|dropdown-term" class="^dropdown-term$"'

term() {
    local cmd
    cmd='exec tmux new-session -A -s dropdown -c "$HOME"'

    if test "$1" = kitty; then
        exec kitty --name "kitty" --class "dropdown-term" --override 'initial_window_width=150c' --override 'initial_window_height=40c' -e bash -c "$cmd"
    else
        exec st -c "dropdown-term" -g 200x60 -e bash -c "$cmd"
    fi
}

i3-msg "[ $FILTER ] scratchpad show, move position center" ||
    i3-msg "[ $FILTER ] move workspace current, focus" ||
    term "$@"

