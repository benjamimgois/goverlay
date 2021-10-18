#!/bin/sh
# This script will Launch Goverlay the correct way
#
# QT_QPA_PLATFORM=xcb will force the application to run in x11 mode, so it works on wayland desktops.
# mangohud --dlsym will force the mangohud display on the spinning cube on goverlay
# --style fusion will make sure the interface doesn't break in diferent DE and QT themes.

QT_QPA_PLATFORM=xcb mangohud --dlsym goverlay --style fusion
