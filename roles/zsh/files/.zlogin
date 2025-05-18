# .zlogin is for login shells. It is sourced on the start of a login shell but after .zshrc,
# if the shell is also interactive.
# This file is often used to start X using startx.
# Some systems start X on boot, so this file is not always very useful.


# See: https://wiki.archlinux.org/title/java#Gray_window,_applications_not_resizing_with_WM,_menus_immediately_closing
# Virtually all modern window managers are re-parenting, although earlier window managers, such as the uwm window manager, were not.
# Exceptions to that rule are dwm, cwm, PLWM, ratpoison and xmonad, due to a lack of any typical window decorations used by these window managers.
## export _JAVA_AWT_WM_NONREPARENTING=1
## export AWT_TOOLKIT=MToolkit

# Refetch the DISPLAY env variable from systemd
eval "export $(systemctl --user show-environment | grep -E 'DISPLAY=:[0-9]+')" 1> /dev/null 2> /dev/null

USE_WAYLAND=0

# Default value in ubuntu
# password requisite pam_pwquality.so minlen=14 dcredit=-1 lcredit=-11 ocredit=-1 ucredit=-1
# mkdir -p /run/intune/"$UID" && echo "password requisite pam_pwquality.so minlen=9 dcredit=1 lcredit=1 ocredit=1 ucredit=1" > /run/intune/"$UID"/pwquality
if test -x /usr/local/bin/intune-fix-pwquality.sh; then
    ## Content of the script (script must be whitelisted in sudo config files, in order to run it as superuser without prompting for password)
    #
    # set -x
    #
    # uid="${1:-$UID}"
    # user="${2:-$USER}"
    #
    # mkdir -p /run/intune/"$uid"
    # touch /run/intune/"$uid"/pwquality
    # echo "password requisite pam_pwquality.so minlen=9 dcredit=1 lcredit=1 ocredit=1 ucredit=1" > /run/intune/"$uid"/pwquality
    #
    # chown -R "$user:$user" /run/intune/"$uid"

    sudo /usr/local/bin/intune-fix-pwquality.sh "$UID" "$USER"
fi


if systemctl -q is-active graphical.target \
    && [ -z "$SSH_CLIENT" ] \
    && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -le 4 ]; then

    if test USE_WAYLAND -eq 1 && uwsm check may-start && uwsm select; then
        exec systemd-cat -t uwsm_start uwsm start default
    fi

    # Test connection to Xserver. If it's already running do not create a new one
    if test -z "$DISPLAY" || ! timeout 1s xset q 1> /dev/null 2> /dev/null; then
        if test -x "${XDG_CONFIG_HOME-:$HOME/.config}/xorg/startx"; then
            exec "${XDG_CONFIG_HOME-:$HOME/.config}/xorg/startx"
        fi
    else
        echo "Xorg is already running at DISPLAY=$DISPLAY"
    fi
fi
