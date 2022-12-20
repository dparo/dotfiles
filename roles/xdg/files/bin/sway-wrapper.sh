#!/usr/bin/env bash
# -*- coding: utf-8 -*-


## View: https://github.com/hyprwm/Hyprland/wiki/Nvidia

# export LIBVA_DRIVER_NAME=nvidia
export CLUTTER_BACKEND=wayland
export XDG_SESSION_TYPE=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export MOZ_ENABLE_WAYLAND=1
export GBM_BACKEND=nvidia-drm
export QT_QPA_PLATFORM=wayland
export QT_AUTO_SCREEN_SCALE_FACTOR=1
export GDK_BACKEND=wayland

export WLR_NO_HARDWARE_CURSORS=1
export WLR_BACKEND=vulkan
export WLR_DRM_NO_ATOMIC=1

export XDG_CURRENT_DESKTOP=sway

export __GLX_VENDOR_LIBRARY_NAME=nvidia
export __GL_GSYNC_ALLOWED=0
export __GL_VRR_ALLOWED=0

sway --unsupported-gpu
