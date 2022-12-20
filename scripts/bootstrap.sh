#!/usr/bin/env bash

set -x
set -e

source /etc/os-release

if ! test -x "$(command -v ansible)"; then
    case $ID in
    ubuntu)
        sudo apt update
        sudo apt install -y git ansible
        ;;

    arch)
        sudo pacman -S --noconfirm git ansible
        ;;
    esac
fi

install() {
    source "$PWD/scripts/lib.sh" || exit 1

    set +x
    ask_vault_pass
    set -x

    git_exclude

    ./scripts/install.sh "$@"
}

main() {
    if test -n "$1"; then
        DOTFILES_LOCATION="$1"
        shift 1
    else
        DOTFILES_LOCATION="${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles"
    fi

    local cloned=0
    if ! test -d "$DOTFILES_LOCATION"; then
        mkdir -p "$DOTFILES_LOCATION"
        git clone --recursive "https://github.com/dparo/dotfiles" "$DOTFILES_LOCATION"
        cloned=1
    fi


    pushd "$DOTFILES_LOCATION" || exit 1
    install "$@"
    local rc=$?
    popd || exit 1


    if test "$rc" -eq 0 && test "$cloned" -eq 1; then
        while true; do
            echo ""
            echo ""
            echo ""
            echo "It is recommended to reboot after installing the dotfiles for the first time."
            read -p -r "Do you want to reboot now? [yn]" yn
            case $yn in
            [Yy]*) systemctl reboot ;;
            [Nn]*) ;;
            *) echo "Please answer yes or no." ;;
            esac
        done
    fi
}

main "$@"
