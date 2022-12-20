#!/usr/bin/env bash
# -*- coding: utf-8 -*-

if [ -f "$HOME/intel/oneapi/setvars.sh" ]; then
	source "$HOME/intel/oneapi/setvars.sh"
	exec vtune-gui "$@"
else
	echo >&2 "Intel VTUNE seems to not be installed"
	exit 1
fi
