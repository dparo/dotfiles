#!/bin/bash


if $(hash vd); then
    vd $@
else
    set -x
    pip3 install visidata
    vd $@
fi
