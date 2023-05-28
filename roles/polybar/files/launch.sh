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
    killall --quiet --user polybar
    while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done


    local list_of_monitors
    list_of_monitors="$(polybar --list-monitors | cut -d":" -f1)"

    readarray -t list_of_monitors_array i <<<"$list_of_monitors"

    for m in "${list_of_monitors_array[@]}"; do
        env MONITOR="$m" polybar --reload main &
    done
}

set -e
main "$@"
