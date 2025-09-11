#!/usr/bin/env bash
# -*- coding: utf-8 -*-
FILTER='instance="teams-for-linux|microsoft teams|crx_+cifhbcnohmdccbgoicgdjpfamggdegmo" class="teams-for-linux|Microsoft Teams|Google-chrome|Microsoft-edge|Brave-browser|Chromium-browser"'

i3-msg "[ $FILTER ] scratchpad show, move position center" ||
    i3-msg "[ $FILTER ] focus" ||
    gtk-launch teams-for-linux.desktop

