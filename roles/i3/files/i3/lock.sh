#!/usr/bin/env bash
# -*- coding: utf-8 -*-


FILTER='instance="spotify" class="Spotify"'

xset s activate

spotify-ctl.sh pause
sleep 1

i3-msg "[ $FILTER ] kill"
