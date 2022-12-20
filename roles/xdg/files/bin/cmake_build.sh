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

find ./ -maxdepth 3 -type f -name CMakeCache.txt | uniq | while IFS= read -r line; do
	dir="$(dirname "$line")"
	dir="$(readlink -f "$dir")"
	config="$(basename "$dir")"

	echo -e "${PURPLE}Building $dir...$NC"

	# Call cmake and forward all the extra arguments
	nprocs=$(echo "($(nproc) * 0.75) / 1" | bc)
	if [[ nprocs -le 0 ]]; then
		nprocs=1
	fi

	if ! cmake --build "$dir" --config "$config" -j "$nprocs" "$@"; then
		exit 1
	fi
done
