#!/usr/bin/env bash
# -*- coding: utf-8 -*-

FILTER='instance="insomnia" class="Insomnia"'

i3-msg "[ $FILTER ] scratchpad show, move position center" ||
    i3-msg "[ $FILTER ] focus" ||
    exec gtk-launch insomnia
