#!/bin/bash

sudo wipefs --all "$2" && sudo dd bs=4M if="$1" of="$2" conv=fsync status=progress oflag=direct
