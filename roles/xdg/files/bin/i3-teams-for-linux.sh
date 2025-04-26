#!/usr/bin/env bash
# -*- coding: utf-8 -*-
FILTER='instance="teams-for-linux|microsoft teams" class="teams-for-linux|Microsoft Teams"'

i3-msg "[ $FILTER ] scratchpad show, move position center" ||
    i3-msg "[ $FILTER ] focus" ||
    gtk-launch teams-for-linux.desktop

