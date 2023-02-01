#!/usr/bin/env bash

set_wallpaper() {
    for v in "$@"; do
        if [ "$v" != "" ] && [ -f "$v" ]; then
            (feh --no-fehbg --bg-fill "$v" || nitrogen --set-zoom-fill "$v") && return 0
        fi
    done
    return 1
}

set_wallpaper \
    /usr/share/backgrounds/fedora-workstation/glasscurtains_dark.webp \
    /usr/share/backgrounds/gnome/adwaita-d.webp
