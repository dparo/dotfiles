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
    local mvn_config_location
    mvn_config_location="${XDG_CONFIG_HOME:-$HOME/.config}/maven"

    pushd "$mvn_config_location/templates" || exit 1
    t="$(find ./ | grep -E --invert-match '^(\./)?main.xml.j2$' | grep -E --invert-match '^(\./)?head.xml.j2$' | grep -E '.*.j2$' | fzf)"

    python3 <(cat <<EOF
import sys
import os

from jinja2 import Environment, FileSystemLoader

dir = os.path.join(os.path.expanduser('~'), '.config', 'maven', 'templates')
out_file = os.path.join(os.path.expanduser('~'), '.config', 'maven', 'settings_current.xml')
env = Environment(loader=FileSystemLoader(dir))
template = env.get_template(sys.argv[1])
rendered_content = template.render()
with open(out_file, 'w') as f:
    f.write(rendered_content)
EOF
) "$t"

    pushd "$mvn_config_location" || exit 1
    ln --force -s "settings_current.xml" "settings_local.xml"
    popd
    popd
}

set -x
main "$@"
