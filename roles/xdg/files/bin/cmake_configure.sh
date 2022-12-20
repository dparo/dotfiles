#!/usr/bin/env bash

cd "$(git rev-parse --show-toplevel)" || exit 1

TOP_DIR=$PWD

if [ -t 1 ]; then
	# Im outputting to terminal
	RED='\033[0;31m'
	PURPLE='\033[0;35m'
	NC='\033[0m'
else
	# Not a terminal
	RED=''
	PURPLE=''
	NC=''
fi

for M in Debug Release RelWithDebInfo; do
	BUILD_DIR="build/$M"
	command rm -rfd "$BUILD_DIR"
	mkdir -p "$BUILD_DIR"

	TOP_DIR=$(readlink -f "$TOP_DIR")
	BUILD_DIR=$(readlink -f "$BUILD_DIR")

	echo -e "${PURPLE}Configuring $M...$NC"

	# NOTE: Cmake Unix Makefiles generator is nicer: it produces colored output and error messages use absolute paths, so it is easier to use vim to jump to error locations
	#       Ninja produces uncolored error messages with relative paths to the build directory which are unresolvable from the vim editor

	if ! cmake -DCMAKE_BUILD_TYPE="$M" -DCMAKE_COLOR_MAKEFILE=ON -DCMAKE_EXPORT_COMPILE_COMMANDS=YES -S "$TOP_DIR" -B "$BUILD_DIR" -G "Ninja" "$@"; then
		exit 1
	fi
done

ln -f -s -r build/Debug/compile_commands.json ./compile_commands.json
