#!/usr/bin/env bash

cd "$(git rev-parse --show-toplevel)" || exit 1

# Not a terminal
RED=''
PURPLE=''
NC=''

if [ -t 1 ]; then
	# Im outputting to terminal
	RED='\033[0;31m'
	PURPLE='\033[0;35m'
	NC='\033[0m'
fi

run_test() {
	pushd "$1" || exit 1
	# Call ctest and forward remaining arguments here

	echo -e "${PURPLE}Testing  ${1}...$NC"
	BUILD_TYPE="$(basename "$1")"
	if ! ctest --force-new-ctest-process --output-on-failure -j "$(nproc)" -C "$BUILD_TYPE" "${@:2}"; then
		exit 1
	fi
	popd || exit 1
}

if ! cmake_build.sh; then
	# Exit with 125 exit code to be friendly with git-bisect
	exit 125
fi

find ./ -maxdepth 3 -type f -name CMakeCache.txt | uniq | while IFS= read -r line; do
	dir="$(dirname "$line")"
	dir="$(readlink -f "$dir")"
	run_test "$dir" "$@"
done
