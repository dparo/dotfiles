#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#

FILTER='instance="crx__pkooggnaalmfkidjmlhoelhdllpphaga" class="Microsoft-edge"'

i3-msg "[ $FILTER ] scratchpad show, move position center" ||
    i3-msg "[ $FILTER ] focus" ||
    gtk-launch msedge-pkooggnaalmfkidjmlhoelhdllpphaga-Default.desktop
