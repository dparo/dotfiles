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
    # eval "export $(systemctl --user show-environment | grep DBUS_SESSION_BUS_ADDRESS)"
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$UID/bus"
fi

if test -z "$XAUTHORITY" -a ! -f "$XAUTHORITY"; then
    export XAUTHORITY="$XDG_RUNTIME_DIR/Xauthority"
fi
export XCURSOR_PATH="/usr/share/icons:$XDG_DATA_HOME/icons:$XCURSOR_PATH"


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


export ANSIBLE_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/ansible"
export ANSIBLE_CONFIG="${XDG_CONFIG_HOME}/ansible.cfg"
export ANSIBLE_GALAXY_CACHE_DIR="${XDG_CACHE_DIR:-$HOME/.cache}/ansible/galaxy"
export ANSIBLE_LOCAL_TEMP="${XDG_CACHE_DIR:-$HOME/.cache}/ansible/tmp"


export PNPM_HOME="/home/dparo/.local/share/pnpm"

# Setup programs default config location to avoid cluttering the HOME directory
export XINITRC="$XDG_CONFIG_HOME/xorg/xinitrc"
export XSERVERRC="$XDG_CONFIG_HOME/xorg/xserverrc"
export INPUTRC="$XDG_CONFIG_HOME/readline/inputrc"
export LESSHISTFILE="$XDG_CACHE_HOME/lesshst"
export ASPELL_CONF="per-conf $XDG_CACHE_HOME/aspell/aspell.conf; personal $XDG_CACHE_HOME/aspell/en.pws; repl $XDG_CACHE_HOME/aspell/en.prepl"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
export KDEHOME="$XDG_CONFIG_HOME/kde"
# export NPM_CONFIG_PREFIX="$XDG_DATA_HOME/npm"         # NOTE(d.paro): Not compatible with NVM
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NPM_DIR="$XDG_DATA_HOME/npm"
export DENO_DIR="$XDG_DATA_HOME/deno"
export DENO_INSTALL_ROOT="$XDG_DATA_HOME/deno/bin"
export BUN_INSTALL="$XDG_DATA_HOME/bun"
export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"
export PYTHONUSERBASE="$XDG_DATA_HOME/python"
export PYTHONPYCACHEPREFIX="$XDG_CACHE_HOME/python"
export PYTHON_HISTORY="$XDG_STATE_HOME/python_history"
export IPYTHONDIR="$XDG_CONFIG_HOME/ipython"
export CONDARC="$XDG_CONFIG_HOME/conda/condarc"
export PYLINTHOME="${XDG_CACHE_HOME}/pylint"
export MYPY_CACHE_DIR="$XDG_CACHE_HOME/mypy"
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME/jupyter"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export GOPATH="$XDG_DATA_HOME/go"
export NIMBLE_DIR="$XDG_DATA_HOME/nimble"
export OPAMROOT="$XDG_DATA_HOME/opam"
export NODE_REPL_HISTORY="$XDG_STATE_HOME/node_repl_history"
export TS_NODE_HISTORY="$XDG_STATE_HOME/ts_node_repl_history"
export TEXMFHOME="$XDG_DATA_HOME/texmf"
export TEXMFVAR="$XDG_CACHE_HOME/texlive/texmf-var"
export TEXMFCONFIG="$XDG_CONFIG_HOME/texlive/texmf-config"
export CALCHISTFILE="$XDG_CACHE_HOME/calc_history"
export WGETRC="$XDG_CONFIG_HOME/wgetrc"
export PARALLEL_HOME="$XDG_CONFIG_HOME/parallel"
export W3M_DIR="$XDG_DATA_HOME/w3m"
export CUDA_CACHE_PATH="$XDG_CACHE_HOME/nv"
export __GL_SHADER_DISK_CACHE_PATH="$XDG_CACHE_HOME/nv"
export ANDROID_HOME="$HOME/opt/android-sdk"
export ANDROID_NDK_ROOT="$HOME/opt/android-ndk"
export ANDROID_USER_HOME="$XDG_DATA_HOME/android"
export ANDROID_EMULATOR_HOME="$ANDROID_USER_HOME"
export ANDROID_AVD_HOME="$ANDROID_HOME/avd"
export WINEPREFIX="$XDG_DATA_HOME/wine"
export NPM_CONFIG_REGISTRY="https://registry.npmjs.org/"
export NVM_DIR="$XDG_CONFIG_HOME/nvm"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"

export MYSQL_HISTFILE="$XDG_DATA_HOME/mysql_history"
export PSQL_HISTORY="$XDG_DATA_HOME/psql_history"
export SQLITE_HISTORY="$XDG_CACHE_HOME/sqlite_history"
export REDISCLI_HISTFILE="$XDG_STATE_HOME/rediscli_history"
export REDISCLI_RCFILE="$XDG_CONFIG_HOME/redis/redisclirc"

export VCPKG_DISABLE_METRICS=1
export VCPKG_USE_SYSTEM_BINARIES=1

export AWS_SHARED_CREDENTIALS_FILE="$XDG_DATA_HOME/aws/credentials"
export AWS_CONFIG_FILE="$XDG_CONFIG_HOME/aws/config"

export REBEL_BASE="$XDG_CONFIG_HOME/jrebel"

export DOTNET_CLI_HOME="$XDG_DATA_HOME/dotnet"
export NUGET_PACKAGES="$XDG_CACHE_HOME/nuget"
# export JAVA_USER_HOME="$XDG_DATA_HOME/java"
export SONARLINT_USER_HOME="$XDG_DATA_HOME/sonarlint"

export MINIKUBE_HOME="$XDG_DATA_HOME/minikube"
export PULUMI_HOME="$XDG_DATA_HOME/pulumi"

export COMPOSER_HOME="$XDG_DATA_HOME/composer"
export PASSWORD_STORE_DIR="$XDG_DATA_HOME/password-store"

export ZK_NOTEBOOK_DIR="$HOME/notebook"

# _JAVA_OPTIONS is picked up from the JVM, thus it applies to all JAVA programs. See: https://sourcegraph.com/github.com/openjdk/jdk@91292d5/-/blob/src/hotspot/share/runtime/arguments.cpp?L3233:17&popover=pinned
# JAVA_OPTS: Is used by many shell launcher scripts to pass JVM options to the wrapped programs.
#        Not all java programs use this environment variable, but it is preferred over _JAVA_OPTIONS whenever possible
# java.util.prefs.userRoot --- See: https://sourcegraph.com/github.com/openjdk/jdk@91292d5/-/blob/src/java.prefs/unix/classes/java/util/prefs/FileSystemPreferences.java?L124:17&subtree=true&popover=pinned#tab=def
# export _JAVA_OPTIONS="$_JAVA_OPTIONS -Djava.util.prefs.userRoot=\"$XDG_CONFIG_HOME\" -Drebel.base=\"$REBEL_BASE\""

# Hack for fixing the OpenJDK implementation from creating fontcache files in ~/.java/fonts.
# See: https://sourcegraph.com/github.com/openjdk/jdk@91292d56a9c2b8010466d105520e6e898ae53679/-/blob/src/java.desktop/unix/classes/sun/font/FcFontConfiguration.java?L358:18&popover=pinned#tab=references
#   The openjdk implementation hardcodes the location of the fontcache file regardless if the user specified java.util.prefs.userRoot to a different location
# export _JAVA_OPTIONS="$_JAVA_OPTIONS -Duser.home=\"$JAVA_USER_HOME\""

# Setup JAVAFX
# export _JAVA_OPTIONS="$_JAVA_OPTIONS -Djavafx.cachedir=\"$XDG_CACHE_HOME/openjfx\""


##
## Better font rendering for Java applications, useful if not running xsettings daemon
##   NOTE(dparo): IntelliJ complains if this variable is set. It may cause performance degradations.
##
# export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel'


# https://www.oracle.com/java/technologies/javase/9-enhancements.html
# NOTE(d.paro): From JDK 9, _JAVA_OPTIONS is deprecated in favour of JDK_JAVA_OPTIONS,
#               which it evens support more features.
# export JDK_JAVA_OPTIONS="$_JAVA_OPTIONS"






export MAVEN_HOME="$HOME/opt/apache-maven-3.8.6/"
# M2_HOME is used from mvnw (Maven wrapper script)
export M2_HOME="$MAVEN_HOME"

# This variable contains parameters used to start up the JVM running Maven.
# export MAVEN_OPTS="$JAVA_OPTS -Xmx512m -Xverify:none -XX:TieredStopAtLevel=1 -XX:-TieredCompilation"

# Supported only from Maven 4
export MAVEN_ARGS="-gs $XDG_CONFIG_HOME/maven/settings_global.xml"

# For compatibility with maven-wrapper scripts (https://github.com/takari/maven-wrapper)
export MAVEN_CONFIG="-gs $XDG_CONFIG_HOME/maven/settings_global.xml"

export MAVEN_DEBUG_ADDRESS=5005

export SPLUNK_HOME="$HOME/opt/splunk"

# Default CMAKE_GENERATOR
export CMAKE_GENERATOR=Ninja
export CONAN_CMAKE_GENERATOR="$CMAKE_GENERATOR"
export CONAN_USER_HOME="$XDG_CONFIG_HOME"
# export CPM_SOURCE_CACHE="$XDG_CACHE_HOME/CPM"


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

# IBM MQ Redist Client
if [ -d "/opt/mqm/lib64" ]; then
    export LD_LIBRARY_PATH="/opt/mqm/lib64:$LD_LIBRARY_PATH"
fi

export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
--highlight-line \
--info=inline-right \
--ansi \
--layout=reverse \
--border=none \
--color=bg+:#2e3c64 \
--color=bg:#1f2335 \
--color=border:#29a4bd \
--color=fg:#c0caf5 \
--color=gutter:#1f2335 \
--color=header:#ff9e64 \
--color=hl+:#2ac3de \
--color=hl:#2ac3de \
--color=info:#545c7e \
--color=marker:#ff007c \
--color=pointer:#ff007c \
--color=prompt:#2ac3de \
--color=query:#c0caf5:regular \
--color=scrollbar:#29a4bd \
--color=separator:#ff9e64 \
--color=spinner:#ff007c \
"

if [ -f "$ZDOTDIR/.localprofile" ]; then
    source "$ZDOTDIR/.localprofile"
fi


