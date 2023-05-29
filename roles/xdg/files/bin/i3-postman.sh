#!/usr/bin/env bash
# -*- coding: utf-8 -*-

FILTER='instance="postman" class="Postman"'

i3-msg "[ $FILTER ] scratchpad show, move position center" ||
    i3-msg "[ $FILTER ] focus" ||
    gtk-launch postman
