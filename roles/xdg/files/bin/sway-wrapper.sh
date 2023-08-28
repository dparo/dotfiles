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

# https://wiki.archlinux.org/title/java#Gray_window,_applications_not_resizing_with_WM,_menus_immediately_closing
export _JAVA_AWT_WM_NONREPARENTING=1 # For JAVA <= 1.8
export AWT_TOOLKIT=MToolkit          # For JAVA > 1.8

export WLR_NO_HARDWARE_CURSORS=1
export WLR_BACKEND=vulkan
export WLR_DRM_NO_ATOMIC=1

export XDG_CURRENT_DESKTOP=sway

export __GLX_VENDOR_LIBRARY_NAME=nvidia
export __GL_GSYNC_ALLOWED=0
export __GL_VRR_ALLOWED=0

exec sway --unsupported-gpu
