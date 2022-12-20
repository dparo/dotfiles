#!/usr/bin/env bash

## Platforms with a built-in command-not-found handler init file
## Inspired from: https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/command-not-found/command-not-found.plugin.zsh


# Debian and derivatives: https://launchpad.net/ubuntu/+source/command-not-found
if [[ -x /usr/lib/command-not-found || -x /usr/share/command-not-found/command-not-found ]]; then
    function command_not_found_handler {
        if [[ -x /usr/lib/command-not-found ]]; then
            /usr/lib/command-not-found -- "$1"
            return $?
        elif [[ -x /usr/share/command-not-found/command-not-found ]]; then
            /usr/share/command-not-found/command-not-found -- "$1"
            return $?
        else
            printf "zsh: command not found: %s\n" "$1" >&2
            return 127
        fi
    }
fi


# Arch Linux command-not-found support, you must have package pkgfile installed
# https://wiki.archlinux.org/index.php/Pkgfile#.22Command_not_found.22_hook
[[ -f /usr/share/doc/pkgfile/command-not-found.zsh ]] && source /usr/share/doc/pkgfile/command-not-found.zsh


# Fedora command-not-found support
if [[ -x /usr/libexec/pk-command-not-found ]]; then
    function command_not_found_handler {
        if [[ -S /var/run/dbus/system_bus_socket && -x /usr/libexec/packagekitd ]]; then
            /usr/libexec/pk-command-not-found "$@"
            return $?
        else
            printf "zsh: command not found: %s\n" "$1" >&2
            return 127
        fi
    }
fi

# NixOS: https://github.com/NixOS/nixpkgs/tree/master/nixos/modules/programs/command-not-found
if [[ -x /run/current-system/sw/bin/command-not-found ]]; then
    function command_not_found_handler {
        /run/current-system/sw/bin/command-not-found "$@"
        return $?
    }
fi


# SUSE and derivates: https://www.unix.com/man-page/suse/1/command-not-found/
if [[ -x /usr/bin/command-not-found ]]; then
    function command_not_found_handler {
        /usr/bin/command-not-found "$1"
        return $?
    }
fi
