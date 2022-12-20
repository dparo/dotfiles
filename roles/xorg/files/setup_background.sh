#!/usr/bin/env bash

# WALLPAPER="${1:-$XDG_DATA_HOME/backgrounds/4k.png}"
# WALLPAPER="${1:-$XDG_DATA_HOME/backgrounds/abstract-blue-blobs.png}"
# WALLPAPER="${1:-$XDG_DATA_HOME/backgrounds/adwaita-d42.jpg}"
# WALLPAPER="${1:-$XDG_DATA_HOME/backgrounds/adwaita-d43.jpg}"
# WALLPAPER="${1:-$XDG_DATA_HOME/backgrounds/lake-of-rage.jpg}"
# WALLPAPER="${1:-$XDG_DATA_HOME/backgrounds/night-city-art.png}"
# WALLPAPER="${1:-$XDG_DATA_HOME/backgrounds/aesthetic_dear_color_palette.png}"
# WALLPAPER="${1:-$XDG_DATA_HOME/backgrounds/bird_1.jpg}"
#WALLPAPER="${1:-$XDG_DATA_HOME/backgrounds/canvas-material-darker.png}"
# WALLPAPER="${1:-$XDG_DATA_HOME/backgrounds/nebula.jpg}"
WALLPAPER="${1:-$XDG_DATA_HOME/backgrounds/mountains.webp}"


LOCK_WALLPAPER="${2:-$XDG_DATA_HOME/backgrounds/stand_back_im_going_to_try_science.jpg}"

create_locked_screen_img() {
	screen_width=$(xdpyinfo | grep dimensions | cut -d\  -f7 | cut -dx -f1)
	screen_size=$(xdpyinfo | grep dimensions | sed -r 's/^[^0-9]*([0-9]+x[0-9]+).*$/\1/')

	flags="-resize $screen_width -gravity center -crop $screen_size+0+0 +repage -fill black"

	if [ "$LOCK_WALLPAPER" = "" ] || [ "$LOCK_WALLPAPER" == "$WALLPAPER" ]; then
		flags="$flags -colorize 80%"
	fi

	convert "$flags" "$LOCK_WALLPAPER" ~/.cache/locked-screen.png
}

set_wallpaper() {
	if [ "$WALLPAPER" != "" ] && [ -f "$WALLPAPER" ]; then
		feh --no-fehbg --bg-fill "$WALLPAPER" || nitrogen --set-zoom-fill "$WALLPAPER"
	fi
}

#wal -c
#wal -n -a 80 -s -t -i "$WALLPAPER"
# create_locked_screen_img & disown
set_wallpaper
