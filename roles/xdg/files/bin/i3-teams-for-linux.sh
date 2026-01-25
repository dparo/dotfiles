#!/usr/bin/env bash
# -*- coding: utf-8 -*-

FILTER='instance="teams-for-linux|microsoft teams|crx_+cifhbcnohmdccbgoicgdjpfamggdegmo" class="teams-for-linux|Microsoft Teams|Google-chrome|Microsoft-edge|Brave-browser|Chromium-browser"'

# Detect sway (Wayland) vs i3 (X11)
if [ -n "$SWAYSOCK" ] || [ -n "$WAYLAND_DISPLAY" ]; then
    MSG="swaymsg"
    FILTER='instance="teams-for-linux|microsoft teams|crx_+cifhbcnohmdccbgoicgdjpfamggdegmo" class="teams-for-linux|Microsoft Teams|Google-chrome|Microsoft-edge|Brave-browser|Chromium-browser"'
else
    MSG="i3-msg"
    FILTER='instance="teams-for-linux|microsoft teams|crx_+cifhbcnohmdccbgoicgdjpfamggdegmo" class="teams-for-linux|Microsoft Teams|Google-chrome|Microsoft-edge|Brave-browser|Chromium-browser"'
fi

$MSG "[ $FILTER ] scratchpad show, move position center" ||
    $MSG "[ $FILTER ] focus" ||
    gtk-launch teams-for-linux.desktop

