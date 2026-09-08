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


function cleanup_intellij_idea_old_dirs() {
    keep=1
    delete=false
    [[ ${1:-} == "--delete" ]] && delete=true

    root="${XDG_DATA_HOME:-$HOME/.local/share}/JetBrains"
    [[ -d $root ]] || exit 0

    mapfile -d '' -t dirs < <(
        find "$root" -mindepth 1 -maxdepth 1 -type d \
            -name 'IntelliJIdea[0-9]*' -print0 |
        sort -zV
    )

    remove_count=$((${#dirs[@]} - keep))
    ((remove_count > 0)) || exit 0

    for ((i = 0; i < remove_count; i++)); do
        dir=${dirs[i]}
        name=${dir##*/}

        # Extra guard against deleting unrelated directories.
        [[ $name =~ ^IntelliJIdea[0-9]{4}\.[0-9]+([.][0-9]+)?$ ]] || continue

        if $delete; then
            echo "Deleting $dir"
            rm -rf -- "$dir"
        else
            echo "Would delete $dir"
        fi
    done
}


set -x

dnf clean all
sudo dnf clean all
sudo dnf autoremove

rm -rf "$HOME/.cache/pre-commit/"

go clean -modcache
go clean -cache
pip cache purge
uv cache clean

docker builder prune -f

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

# Delete nvim undo history, older than 90 days
find /home/dparo/.cache/nvim/nvim/undo -type f -mtime +90 -delete
#   Otherwise go for hard delete: rm -rf /home/dparo/.cache/nvim/nvim/undo/

cleanup_intellij_idea_old_dirs --delete

