#!/usr/bin/env bash

# set the icon and a temporary location for the screenshot to be stored
tmpbg="/tmp/i3agls_$USER.png"

# take a screenshot
scrot "$tmpbg"

# blur the screenshot by resizing and scaling back up
convert "$tmpbg" -blur 16x8 "$tmpbg"
#convert "$tmpbg" -filter Gaussian -thumbnail 20% -sample 500% "$tmpbg"

# lock the screen with the blurred screenshot
i3lock -i "$tmpbg"
