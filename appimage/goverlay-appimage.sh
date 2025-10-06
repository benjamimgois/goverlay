#!/bin/sh

set -eu

# make appimage
export ARCH="$(uname -m)"
export APPIMAGE_EXTRACT_AND_RUN=1
export VERSION="$(echo "$GITHUB_SHA" | cut -c 1-9)"
UPINFO="gh-releases-zsync|$(echo "$GITHUB_REPOSITORY" | tr '/' '|')|latest|*$ARCH.AppImage.zsync"
LIB4BN="https://raw.githubusercontent.com/VHSgunzo/sharun/refs/heads/main/lib4bin"
URUNTIME="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/uruntime2appimage.sh"

export DESKTOP=/usr/share/applications/io.github.benjamimgois.goverlay.desktop
export ICON=/usr/share/icons/hicolor/256x256/apps/goverlay.png
export OUTNAME=GOverlay-"$VERSION"-anylinux-"$ARCH".AppImage

# Prepare AppDir
mkdir -p ./AppDir
cd ./AppDir

# ADD LIBRARIES
wget "$LIB4BN" -O ./lib4bin
chmod +x ./lib4bin
xvfb-run -a -- ./lib4bin -p -v -e -s -k \
	/usr/lib/goverlay \
	/usr/lib/mangohud/* \
	/usr/bin/vkcube \
	/usr/bin/vkcube-wayland \
	/usr/bin/lspci \
	/usr/lib/qt6/plugins/iconengines/* \
	/usr/lib/qt6/plugins/imageformats/* \
	/usr/lib/qt6/plugins/platforms/* \
	/usr/lib/qt6/plugins/platformtheme/* \
	/usr/lib/qt6/plugins/styles/* \
	/usr/lib/qt6/plugins/xcbglintegrations/* \
	/usr/lib/qt6/plugins/wayland-*/*

# VERY IMPORTANT!
cp -rv /usr/share/vulkan/implicit_layer.d ./share/vulkan
sed -i 's|/usr/lib/mangohud/||' ./share/vulkan/implicit_layer.d/*

echo 'MANGOHUD=1' > ./.env
echo 'libMangoHud_shim.so' > ./.preload

# Goverlay is also going to run sh -c mangohud vkcube so we need to wrap this
echo '#!/bin/sh
CURRENTDIR="$(dirname "$(readlink -f "$0")")"
shift
"$CURRENTDIR"/vkcube "$@"' > ./bin/mangohud
chmod +x ./bin/mangohud

ln ./sharun ./AppRun
./sharun -g

# make appimage with uruntime
cd ..
wget --retry-connrefused --tries=30 "$URUNTIME" -O ./uruntime2appimage
chmod +x ./uruntime2appimage
./uruntime2appimage
