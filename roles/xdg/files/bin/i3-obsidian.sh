#!/usr/bin/env bash
# -*- coding: utf-8 -*-

FILTER='instance="obsidian" class="obsidian" window_role="browser-window"'

i3-msg "[ $FILTER ] scratchpad show, move position center" \
    || i3-msg "[ $FILTER ] focus" \
    || gtk-launch obsidian.desktop
