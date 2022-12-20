#!/usr/bin/env bash
# -*- coding: utf-8 -*-

cd "$(dirname "$0")/../" || exit 1

# Remove previous images
docker rmi --force "$(docker images | grep dparo-dotfiles | tr -s ' ' | cut -d ' ' -f 3)"
docker build -t dparo-dotfiles . && exec docker run -it dparo-dotfiles
