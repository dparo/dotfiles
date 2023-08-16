#!/usr/bin/env bash
# -*- coding: utf-8 -*-

set -eou pipefail

if builtin type readlink 1>/dev/null 2>/dev/null; then
    # shellcheck disable=SC2034
    SELF_BASH_SCRIPT_DIR="$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")"
else
    # shellcheck disable=SC2034
    SELF_BASH_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
fi


echoerr() { echo "$@" 1>&2; }

main() {
    cd "$SELF_BASH_SCRIPT_DIR" || exit 1

    echo "Hello world"
}

set -x
main "$@"
