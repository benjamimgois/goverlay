#!/bin/sh

set -eu

# make appimage
ARCH="$(uname -m)"
VERSION="$(echo "$GITHUB_SHA" | cut -c 1-9)"
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"
URUNTIME="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/uruntime2appimage.sh"

export DESKTOP=/usr/share/applications/io.github.benjamimgois.goverlay.desktop
export ICON=/usr/share/icons/hicolor/256x256/apps/goverlay.png
export DEPLOY_OPENGL=1
export DEPLOY_VULKAN=1
export UPINFO="gh-releases-zsync|$(echo "$GITHUB_REPOSITORY" | tr '/' '|')|latest|*$ARCH.AppImage.zsync"
export OUTNAME=GOverlay-"$VERSION"-anylinux-"$ARCH".AppImage

# ADD LIBRARIES
wget --retry-connrefused --tries=30 "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun
./quick-sharun \
	/usr/lib/goverlay        \
	/usr/lib/pascube/pascube \
	/usr/lib/mangohud/*      \
	/usr/lib/libvkbasalt.so* \
	/usr/bin/vkcube          \
	/usr/bin/lspci           \
	/usr/bin/mangohud
cp -v /usr/share/vulkan/implicit_layer.d/vkBasalt.json ./share/vulkan/implicit_layer.d

# make appimage with uruntime
wget --retry-connrefused --tries=30 "$URUNTIME" -O ./uruntime2appimage
chmod +x ./uruntime2appimage
./uruntime2appimage
