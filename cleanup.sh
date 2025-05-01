#!/usr/bin/env bash
# -*- coding: utf-8 -*-

set -eou pipefail

# Load OS information
if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "Cannot determine OS. /etc/os-release not found."
    exit 1
fi

# Check the distribution ID
case "$ID" in
    ubuntu)
        echo "Running on Ubuntu"
        ;;
    arch)
        echo "Running on Arch Linux"

    ;;
    fedora)
        echo "Running on Fedora"
        ;;
    *)
        echo "Running on an unsupported distribution: $ID"
        ;;
esac




go clean -modcache
go clean -cache
pip cache purge

npm cache clean --force

flatpak uninstall --unused

if test "$ID" = "arch" && command -v yay >/dev/null 2>&1; then
    yay -Scc --no-confirm
fi

