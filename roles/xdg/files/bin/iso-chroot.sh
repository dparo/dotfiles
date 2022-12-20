#!/usr/bin/env bash
# -*- coding: utf-8 -*-

cd "$(dirname "$0")" || exit 1


die() {
    >&2 echo "$@"
    exit 1
}

(( $# )) || die 'No chroot directory specified'

chrootdir="$1"
shift

[[ -d $chrootdir ]] || die "Can't create chroot on non-directory" "$chrootdir"
 (( EUID == 0 )) || die 'This script must be run with root privileges'

for i in dev proc sys run; do sudo mount --bind "/$i" "/$chrootdir/$i"; done


##
## From arch-chroot. These might not be needed
##
#
# mount /proc "$chrootdir/proc" -t proc -o nosuid,noexec,nodev
# mount /sys "$chrootdir/sys" -t sysfs -o nosuid,noexec,nodev,ro
# mount /udev "$chrootdir/dev" -t devtmpfs -o mode=0755,nosuid
# mount /devpts "$chrootdir/dev/pts" -t devpts -o mode=0620,gid=5,nosuid,noexec
# mount /shm "$chrootdir/dev/shm" -t tmpfs -o mode=1777,nosuid,nodev
# mount /run "$chrootdir/run" -t tmpfs -o nosuid,nodev,mode=0755
# mount /tmp "$chrootdir/tmp" -t tmpfs -o mode=1777,strictatime,nodev,nosuid

mount efivarfs "$chrootdir/sys/firmware/efi/efivars" -t efivarfs -o nosuid,noexec,nodev

export SHELL=/bin/bash
sudo chroot "$chrootdir" "$@"
