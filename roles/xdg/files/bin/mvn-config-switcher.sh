#!/usr/bin/env bash
# -*- coding: utf-8 -*-


if builtin type readlink 1>/dev/null 2>/dev/null; then
    # shellcheck disable=SC2034
    SELF_BASH_SCRIPT_DIR="$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")"
else
    # shellcheck disable=SC2034
    SELF_BASH_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
fi


echoerr() { echo "$@" 1>&2; }

main() {
    local mvn_config_location
    mvn_config_location="${XDG_CONFIG_HOME:-$HOME/.config}/maven"

    pushd "$mvn_config_location" || exit 1
    ln --force -s "$(find ./ -type f | grep -E --invert-match '^(\./)?settings_local.xml$' | grep -E --invert-match '^(\./)?settings_global.xml$' | grep -E '.*.xml$' | fzf)" "settings_local.xml"
    popd
}

set -x
set -e
main "$@"
