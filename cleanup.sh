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



rm -rf "$HOME/.cache/pre-commit/"

go clean -modcache
go clean -cache
pip cache purge


npm cache clean --force

flatpak uninstall --unused
flatpak repair --user
sudo flatpak repair

if test "$ID" = "arch" && command -v yay >/dev/null 2>&1; then
    yay -Scc --no-confirm
fi

# Cleanup regularly the Spotify cache directory to avoid huge buildup. See:
# - https://www.reddit.com/r/spotify/comments/14kqpl5/why_is_spotifys_cache_so_crazy_big_mine_is_over/
# - https://www.reddit.com/r/spotify/comments/8fyzqp/why_in_the_world_does_the_spotify_app_cache_eat/
rm -rf /home/dparo/.var/app/com.spotify.Client/cache
