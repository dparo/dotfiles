#!/usr/bin/env bash
# -*- coding: utf-8 -*-

FILTER='instance="crx_pkooggnaalmfkidjmlhoelhdllpphaga" class="Google-chrome"'

i3-msg "[ $FILTER ] scratchpad show, move position center" ||
    i3-msg "[ $FILTER ] focus" ||
    gtk-launch chrome-pkooggnaalmfkidjmlhoelhdllpphaga-Default.desktop
