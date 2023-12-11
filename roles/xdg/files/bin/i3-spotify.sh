#!/usr/bin/env bash
# -*- coding: utf-8 -*-

FILTER='instance="spotify" class="Spotify"'

i3-msg "[ $FILTER ] scratchpad show, move position center" ||
    i3-msg "[ $FILTER ] focus" ||
    flatpak run com.spotify.Client

