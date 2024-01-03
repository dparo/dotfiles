#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# FILTER='instance="kitty" class="^dropdown-term$"'
FILTER='instance="st-256color" class="^dropdown-term$"'

# kitty --name "kitty" --class "dropdown-term" -e tmux new-session -A -s dropdown -c "$HOME"
i3-msg "[ $FILTER ] scratchpad show, move position center" ||
    i3-msg "[ $FILTER ] move workspace current, focus" ||
    st -c "dropdown-term" -g 200x60 -e tmux new-session -A -s dropdown -c "$HOME"

