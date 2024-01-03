#!/usr/bin/env bash
# -*- coding: utf-8 -*-

FILTER='instance="st-256color" class="st-256color" title="^dropdown.*"'

i3-msg "[ $FILTER ] scratchpad show, move position center" ||
    i3-msg "[ $FILTER ] move workspace current, focus" ||
    st -g 200x60 -e tmux new-session -A -s dropdown -c "$HOME"

