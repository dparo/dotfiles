#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# FILTER='instance="kitty" class="^dropdown-term$"'
FILTER='instance="st-256color|kitty|dropdown-term" class="^dropdown-term$"'

term() {
    # exec kitty --name "kitty" --class "dropdown-term" --override 'initial_window_width=200c' --override 'initial_window_height=60c' -e tmux new-session -A -s dropdown -c "$HOME"
    exec st -c "dropdown-term" -g 200x60 -e tmux new-session -A -s dropdown -c "$HOME"
}

i3-msg "[ $FILTER ] scratchpad show, move position center" ||
    i3-msg "[ $FILTER ] move workspace current, focus" ||
    term

