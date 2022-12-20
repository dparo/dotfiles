# .zprofile is for login shells. It is basically the same as .zlogin except
# that it's sourced before .zshrc whereas .zlogin is sourced after .zshrc.
# According to the zsh documentation, ".zprofile is meant as an alternative to .zlogin
# for ksh fans; the two are not intended to be used together,
# although this could certainly be done if desired."
# NOTE(dparo): login shells do not source the zshrc.
#           So .zprofile and .zlogin run one after the other, and behave basically equivalent


# --- DBUS_SESSION_BUS_ADDRESS ---
	# NOTE(dparo): 30 June 2022
	#       - Ubuntu 22.04 fix for dbus and flatpak.
	#         In Arch Linux this variable is already exported in the shell env.
	#         However in Ubuntu this variable is not exported and it causes
	#         certain flatpak programs to not function since they cannot find the DBUS session
	#       - Ubuntu 22.04, Fixes GUI invocation for GPG password when using git commit signing.
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval "export $(systemctl --user show-environment | grep DBUS_SESSION_BUS_ADDRESS)"
fi

# From gnoome-keyring-daemon which is automatically started (enabled) freom systemd at login
export GNOME_KEYRING_CONTROL="/run/user/$UID/keyring"
export SSH_AUTH_SOCK="$GNOME_KEYRING_CONTROL/ssh"
export GNUPGHOME="${HOME}/.gnupg"

# User specific environment and startup programs
export LANGUAGE="en_US"

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LC_NUMERIC="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"


# NOTE(d.paro): Are these environment variables necessary??
export USERXSESSION="$XDG_CACHE_HOME/xorg/xsession"
export USERXSESSIONRC="$XDG_CACHE_HOME/xorg/xsessionrc"
export ALTUSERXSESSION="$XDG_CACHE_HOME/xorg/Xsession"
export ERRFILE="$XDG_CACHE_HOME/xorg/xsession-errors"

export ANSIBLE_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/ansible"
export ANSIBLE_GALAXY_CACHE_DIR="${ANSIBLE_HOME}/galaxy_cache"
export ANSIBLE_LOCAL_TEMP="$ANSIBLE_HOME/tmp"


# Setup programs default config location to avoid cluttering the HOME directory
export XINITRC="$XDG_CONFIG_HOME/xorg/xinitrc"
export XSERVERRC="$XDG_CONFIG_HOME/xorg/xserverrc"
export XAUTHORITY="$XDG_RUNTIME_DIR/Xauthority"
export INPUTRC="$XDG_CONFIG_HOME/readline/inputrc"
export LESSHISTFILE="$XDG_CACHE_HOME/lesshst"
export ASPELL_CONF="per-conf $XDG_CACHE_HOME/aspell/aspell.conf; personal $XDG_CACHE_HOME/aspell/en.pws; repl $XDG_CACHE_HOME/aspell/en.prepl"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
export KDEHOME="$XDG_CONFIG_HOME/kde"
export NPM_CONFIG_PREFIX="$XDG_DATA_HOME/npm"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NPM_DIR="$XDG_DATA_HOME/npm"
export DENO_DIR="$XDG_DATA_HOME/deno"
export DENO_INSTALL_ROOT="$XDG_DATA_HOME/deno/bin"
export BUN_INSTALL="$XDG_DATA_HOME/bun"
export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"
export PYTHONUSERBASE="$XDG_DATA_HOME/python"
export IPYTHONDIR="$XDG_CONFIG_HOME/ipython"
export CONDARC="$XDG_CONFIG_HOME/conda/condarc"
export PYLINTHOME="${XDG_CACHE_HOME}/pylint"
export MYPY_CACHE_DIR="$XDG_CACHE_HOME/mypy"
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME/jupyter"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export GOPATH="$XDG_DATA_HOME/go"
export NIMBLE_DIR="$XDG_DATA_HOME/nimble"
export NODE_REPL_HISTORY="$XDG_CACHE_HOME/node_repl_history"
export TEXMFHOME="$XDG_DATA_HOME/texmf"
export TEXMFVAR="$XDG_CACHE_HOME/texlive/texmf-var"
export TEXMFCONFIG="$XDG_CONFIG_HOME/texlive/texmf-config"
export WGETRC="$XDG_CONFIG_HOME/wgetrc"
export CUDA_CACHE_PATH="$XDG_CACHE_HOME/nv"
export __GL_SHADER_DISK_CACHE_PATH="$XDG_CACHE_HOME/nv"
export ANDROID_HOME="$HOME/opt/android-sdk"
export ANDROID_NDK_ROOT="$HOME/opt/android-ndk"
export ANDROID_USER_HOME="$XDG_DATA_HOME/android"
export ANDROID_EMULATOR_HOME="$ANDROID_USER_HOME"
export ANDROID_AVD_HOME="$ANDROID_HOME/avd"
export WINEPREFIX="$XDG_DATA_HOME/wine"

export PSQL_HISTORY="$XDG_CACHE_HOME/psql_history"


export REBEL_BASE="$XDG_CONFIG_HOME/jrebel"


export JAVA_USER_HOME="$XDG_DATA_HOME/java"


# _JAVA_OPTIONS is picked up from the JVM, thus it applies to all JAVA programs. See: https://sourcegraph.com/github.com/openjdk/jdk@91292d5/-/blob/src/hotspot/share/runtime/arguments.cpp?L3233:17&popover=pinned
# JAVA_OPTS: Is used by many shell launcher scripts to pass JVM options to the wrapped programs.
#        Not all java programs use this environment variable, but it is preferred over _JAVA_OPTIONS whenever possible
# java.util.prefs.userRoot --- See: https://sourcegraph.com/github.com/openjdk/jdk@91292d5/-/blob/src/java.prefs/unix/classes/java/util/prefs/FileSystemPreferences.java?L124:17&subtree=true&popover=pinned#tab=def
export _JAVA_OPTIONS="$_JAVA_OPTIONS -Djava.util.prefs.userRoot=\"$XDG_CONFIG_HOME\" -Drebel.base=\"$REBEL_BASE\""

# Hack for fixing the OpenJDK implementation from creating fontcache files in ~/.java/fonts.
# See: https://sourcegraph.com/github.com/openjdk/jdk@91292d56a9c2b8010466d105520e6e898ae53679/-/blob/src/java.desktop/unix/classes/sun/font/FcFontConfiguration.java?L358:18&popover=pinned#tab=references
#   The openjdk implementation hardcodes the location of the fontcache file regardless if the user specified java.util.prefs.userRoot to a different location
export _JAVA_OPTIONS="$_JAVA_OPTIONS -Duser.home=\"$JAVA_USER_HOME\""


export MAVEN_HOME="$HOME/opt/apache-maven-3.8.6/"
# M2_HOME is used from mvnw (Maven wrapper script)
export M2_HOME="$MAVEN_HOME"

# This variable contains parameters used to start up the JVM running Maven.
export MAVEN_OPTS="$JAVA_OPTS -Xverify:none -XX:TieredStopAtLevel=1 -XX:-TieredCompilation"

# Supported only from Maven 4
export MAVEN_ARGS="-gs $XDG_CONFIG_HOME/maven/settings.xml"

# For compatibility with maven-wrapper scripts (https://github.com/takari/maven-wrapper)
export MAVEN_CONFIG="-gs $XDG_CONFIG_HOME/maven/settings.xml"


# Default CMAKE_GENERATOR
export CMAKE_GENERATOR=Ninja


export STEAM_FRAME_FORCE_CLOSE=1
#export VISUAL="nvim -R -m -M"         # Does not work :(


export MANWIDTH=80
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'


export FZF_DEFAULT_COMMAND='rg -S --files --hidden -g !.ccls-cache -g !.git -g !.vcs -g !.svn'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='find -type d'

export MAKEFLAGS=--no-print-directory


if [ -f "$ZDOTDIR/.localprofile" ]; then
    source "$ZDOTDIR/.localprofile"
fi


##
## Better font rendering for Java applications, useful if not running xsettings daemon
##   NOTE(dparo): IntelliJ complains if this variable is set. It may cause performance degradations.
##
# export JDK_JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel'

# See: https://wiki.archlinux.org/title/java#Gray_window,_applications_not_resizing_with_WM,_menus_immediately_closing
# Virtually all modern window managers are re-parenting, although earlier window managers, such as the uwm window manager, were not.
# Exceptions to that rule are dwm, cwm, PLWM, ratpoison and xmonad, due to a lack of any typical window decorations used by these window managers.
## export _JAVA_AWT_WM_NONREPARENTING=1
## export AWT_TOOLKIT=MToolkit

# Refetch the DISPLAY env variable from systemd
eval "export $(systemctl --user show-environment | grep -E 'DISPLAY=:[0-9]+')" 1> /dev/null 2> /dev/null

if systemctl -q is-active graphical.target \
	&& [ -z "$SSH_CLIENT" ] \
    && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -le 4 ]; then

    # Test connection to Xserver. If it's already running do not create a new one
    if test -z "$DISPLAY" || ! timeout 1s xset q 1> /dev/null 2> /dev/null; then
        exec "${XDG_CONFIG_HOME-:$HOME/.config}/xorg/startx"
    else
        echo "Xorg is already running at DISPLAY=$DISPLAY"
    fi
fi
