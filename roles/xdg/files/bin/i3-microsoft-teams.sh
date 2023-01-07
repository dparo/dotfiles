#!/usr/bin/env bash
# -*- coding: utf-8 -*-

FILTER='instance="crx_cifhbcnohmdccbgoicgdjpfamggdegmo" class="Google-chrome"'

i3-msg "[ $FILTER ] scratchpad show, move position center" ||
    i3-msg "[ $FILTER ] focus" ||
    gtk-launch chrome-cifhbcnohmdccbgoicgdjpfamggdegmo-Default.desktop
