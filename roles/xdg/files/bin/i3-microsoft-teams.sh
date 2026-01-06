#!/usr/bin/env bash
# -*- coding: utf-8 -*-

FILTER='instance="crx_cifhbcnohmdccbgoicgdjpfamggdegmo" class="Google-chrome"'

# Detect sway (Wayland) vs i3 (X11)
if [ -n "$SWAYSOCK" ] || [ -n "$WAYLAND_DISPLAY" ]; then
    MSG="swaymsg"
else
    MSG="i3-msg"
fi

$MSG "[ $FILTER ] scratchpad show, move position center" ||
    $MSG "[ $FILTER ] focus" ||
    gtk-launch chrome-cifhbcnohmdccbgoicgdjpfamggdegmo-Default.desktop
