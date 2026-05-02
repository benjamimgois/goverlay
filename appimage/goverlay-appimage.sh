#!/bin/sh

set -eu

# make appimage
ARCH="$(uname -m)"
VERSION="$(echo "$GITHUB_SHA" | cut -c 1-9)"
export VERSION
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"

export DESKTOP=/usr/share/applications/io.github.benjamimgois.goverlay.desktop
export ICON=/usr/share/icons/hicolor/256x256/apps/io.github.benjamimgois.goverlay.png
export DEPLOY_OPENGL=1
export DEPLOY_VULKAN=1
export UPINFO="gh-releases-zsync|$(echo "$GITHUB_REPOSITORY" | tr '/' '|')|latest-all|*$ARCH.AppImage.zsync"
export OUTNAME=GOverlay-"$VERSION"-anylinux-"$ARCH".AppImage

# ADD LIBRARIES
wget --retry-connrefused --tries=30 "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun
./quick-sharun \
	/usr/lib/goverlay        \
	/usr/bin/pascube         \
	/usr/share/pascube       \
	/usr/lib/mangohud/*      \
	/usr/lib/libvkbasalt.so* \
	/usr/bin/vkcube          \
	/usr/bin/lspci           \
	/usr/bin/mangohud
cp -v /usr/share/vulkan/implicit_layer.d/vkBasalt.json ./AppDir/share/vulkan/implicit_layer.d

# Copy bundled assets & data so icons load inside the AppImage.
# The script may be executed from any cwd (e.g. repo root in CI),
# so resolve paths relative to the script's own directory.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
if [ -d "${PROJECT_ROOT}/assets" ]; then
  cp -r "${PROJECT_ROOT}/assets" ./AppDir/bin/
fi
if [ -d "${PROJECT_ROOT}/data" ]; then
  cp -r "${PROJECT_ROOT}/data" ./AppDir/bin/
fi

# make appimage with uruntime
./quick-sharun --make-appimage
