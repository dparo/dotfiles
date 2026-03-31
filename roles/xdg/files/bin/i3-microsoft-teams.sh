#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# Combined Teams launcher: tries Microsoft Teams (Brave PWA) first,
# then teams-for-linux, then falls back to launching a .desktop file.

# ---------------------------------------------------------------------------
# 1. Pick the correct compositor message tool and set per-app filters
# ---------------------------------------------------------------------------

set -x
FILTER_TFL2=''

if [ -n "$SWAYSOCK" ] || [ -n "$WAYLAND_DISPLAY" ]; then
    MSG="swaymsg"
    FILTER_MS='app_id="brave-cifhbcnohmdccbgoicgdjpfamggdegmo-Default"'
    FILTER_TFL1='app_id="teams-for-linux"'
    FILTER_TFL2='instance="teams-for-linux" class="teams-for-linux"'
else
    MSG="i3-msg"
    FILTER_MS='instance="crx_cifhbcnohmdccbgoicgdjpfamggdegmo" class="Google-chrome"'
    FILTER_TFL1='instance="teams-for-linux|microsoft teams|crx_+cifhbcnohmdccbgoicgdjpfamggdegmo" class="teams-for-linux|Microsoft Teams|Google-chrome|Microsoft-edge|Brave-browser|Chromium-browser"'
fi

# ---------------------------------------------------------------------------
# 2. Priority 1 – Microsoft Teams via Brave PWA
# ---------------------------------------------------------------------------
$MSG "[ $FILTER_MS ] scratchpad show, move position center" 2>/dev/null && exit 0
$MSG "[ $FILTER_MS ] focus"                                 2>/dev/null && exit 0

# ---------------------------------------------------------------------------
# 3. Priority 2 – teams-for-linux (broad filter)
# ---------------------------------------------------------------------------
$MSG "[ $FILTER_TFL1 ] scratchpad show, move position center" 2>/dev/null && exit 0
$MSG "[ $FILTER_TFL1 ] focus"                                 2>/dev/null && exit 0
if [ -n "$FILTER_TFL2" ]; then
    $MSG "[ $FILTER_TFL2 ] scratchpad show, move position center" 2>/dev/null && exit 0
    $MSG "[ $FILTER_TFL2 ] focus"                                 2>/dev/null && exit 0
fi

# ---------------------------------------------------------------------------
# 4. Fallback – launch a .desktop file
#      1st choice: Brave PWA desktop entry
#      2nd choice: teams-for-linux desktop entry
# ---------------------------------------------------------------------------
gtk-launch brave-cifhbcnohmdccbgoicgdjpfamggdegmo-Default.desktop 2>/dev/null && exit 0
gtk-launch teams-for-linux.desktop

