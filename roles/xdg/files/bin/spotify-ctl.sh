#!/usr/bin/env bash
# -*- coding: utf-8 -*-

set -x

##
## Under the hood uses DBUS org.mpris.MediaPlayer2 interface
##
# playerctl -p spotify pause
# playerctl -p spotify play-pause
# playerctl -p spotify play-pause
# playerctl -p spotify stop
# playerctl -p spotify stop
# playerctl -p spotify next
# playerctl -p spotify next
# playerctl -p spotify previous
# playerctl -p spotify previous
# playerctl -p spotify volume 0.05+
# playerctl -p spotify volume 0.05-


mediaplayer="spotify"

# MPD ha priorità se il servizio è attivo e contiene un brano riproducibile.
# MPD ha priorità se il servizio è attivo e ha un brano in play o pausa.
if systemctl --user is-active --quiet mpd 2>/dev/null \
   || systemctl is-active --quiet mpd 2>/dev/null; then

    if mpc status 2>/dev/null | grep -Eqi '^\[(playing|paused)\]'; then
        mediaplayer="mpd"
    fi
fi

playerctl -l | grep -Ei '^spotify$'
spotify_app_running=$?

# Se MPD non è utilizzabile, prova Spotify / Spotifyd.
if test "$spotify_app_running" -ne 0 && test "$mediaplayer" = "spotify"; then
    if ! playerctl -l 2>/dev/null | grep -Eqi '^spotify$'; then
        spotifyd_pid="$(pidof spotifyd 2>/dev/null || true)"
        if [ -n "$spotifyd_pid" ]; then
            mediaplayer="spotifyd.instance${spotifyd_pid}"
        fi
    fi
fi

dbus_send() {
    arg1="$1"
    shift 1
    # https://specifications.freedesktop.org/mpris-spec/2.2/Player_Interface.html
    dbus-send --print-reply --dest="org.mpris.MediaPlayer2.${mediaplayer}" /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player."$arg1" "$@"
}


arg1="$1"
shift 1

if test "$mediaplayer" = "mpd"; then
    case "$arg1" in
        play)
            mpc play;;
        pause)
            mpc pause;;
        play-pause|toggle)
            mpc toggle;;
        stop)
            mpc stop;;
        next)
            mpc next;;
        prev|previous|prior)
            mpc prev;;
        mute)
            mpc volume 0;;
        volume-up)
            mpc volume +5;;
        volume-down)
            mpc volume -5;;
    esac
else
    case "$arg1" in
        play)
            dbus_send Play "$@" || playerctl -p "$mediaplayer" play || playerctl play;;
        pause)
            dbus_send Pause "$@" || playerctl -p "$mediaplayer" pause || playerctl pause;;
        play-pause|toggle)
            dbus_send PlayPause "$@" || playerctl -p "$mediaplayer" play-pause || playerctl play-pause;;
        stop)
            dbus_send Stop "$@" || playerctl -p "$mediaplayer" stop || playerctl stop;;
        next)
            dbus_send Next "$@" || playerctl -p "$mediaplayer" next || playerctl next;;
        prev|previous|prior)
            dbus_send Previous "$@" || playerctl -p "$mediaplayer" previous || playerctl previous;;
        mute)
            dbus_send Volume 0.0 "$@" || playerctl -p "$mediaplayer" volume 0.0 || playerctl volume 0.0;;
        volume-up)
            dbus_send VolumeUp || playerctl -p "$mediaplayer" volume 0.05+ || playerctl volume 0.05+;;
        volume-down)
            dbus_send VolumeDown || playerctl -p "$mediaplayer" volume 0.05- || playerctl volume 0.05-;;
    esac

fi
