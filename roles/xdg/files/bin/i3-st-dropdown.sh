#!/usr/bin/env bash
# -*- coding: utf-8 -*-

FILTER='instance="st-256color" class="st-256color" title="^dropdown@.*"'

i3-msg "[ $FILTER ] scratchpad show, resize set 1024 640, move position center" ||
    i3-msg "[ $FILTER ] focus" ||
    st -e tmux new-session -A -s dropdown -c "$HOME"

