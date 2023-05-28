#!/usr/bin/env bash
# -*- coding: utf-8 -*-

if builtin type readlink 1>/dev/null 2>/dev/null; then
    # shellcheck disable=SC2034
    SELF_BASH_SCRIPT_DIR="$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")"
else
    # shellcheck disable=SC2034
    SELF_BASH_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
fi

main() {
    killall --quiet --user "$USER" polybar | true
    while pgrep -u "$UID" -x polybar >/dev/null; do sleep 1; done

    MONITORS="$(polybar --list-monitors | cut -d":" -f1)"
    PRIMARY=$(xrandr --query | grep " connected" | grep "primary" | cut -d" " -f1)
    readarray -t list_of_monitors_array i <<<"$MONITORS"

    # for m in "${list_of_monitors_array[@]}"; do
    #     env MONITOR="$m" PRIMARY="$PRIMARY" polybar --reload main &
    # done

    env MONITOR="$PRIMARY" PRIMARY="$PRIMARY" polybar --reload main &
}

set -x
main "$@"
