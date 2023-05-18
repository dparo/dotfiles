#!/usr/bin/env bash
# -*- coding: utf-8 -*-

if builtin type readlink 1>/dev/null 2>/dev/null; then
    # Linux
    SELF_BASH_SCRIPT_DIR="$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")"
else
    # Mac OS
    SELF_BASH_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
fi

SELF_BASH_SCRIPT_EXE="$SELF_BASH_SCRIPT_DIR/$(basename "${BASH_SOURCE[0]}")"
cd "$SELF_BASH_SCRIPT_DIR" || exit 1


main() {
    echo "$SELF_BASH_SCRIPT_DIR"
    echo "$SELF_BASH_SCRIPT_EXE"
}

set -x
set -e
main "$@"
