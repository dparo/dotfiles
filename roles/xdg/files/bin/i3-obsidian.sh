#!/usr/bin/env bash
# -*- coding: utf-8 -*-

FILTER='instance="obsidian" class="obsidian" window_role="browser-window"'

# Detect sway (Wayland) vs i3 (X11)
if [ -n "$SWAYSOCK" ] || [ -n "$WAYLAND_DISPLAY" ]; then
    MSG="swaymsg"
else
    MSG="i3-msg"
fi


$MSG "[ $FILTER ] scratchpad show, move position center" \
    || $MSG "[ $FILTER ] focus" \
    || flatpak run md.obsidian.Obsidian \
    || gtk-launch obsidian.desktop
