#!/bin/sh

set -eu

# make appimage
export ARCH="$(uname -m)"
export APPIMAGE_EXTRACT_AND_RUN=1
export VERSION="$GITHUB_SHA"
UPINFO="gh-releases-zsync|$(echo "$GITHUB_REPOSITORY" | tr '/' '|')|latest|*$ARCH.AppImage.zsync"
LIB4BN="https://raw.githubusercontent.com/VHSgunzo/sharun/refs/heads/main/lib4bin"
URUNTIME="https://github.com/VHSgunzo/uruntime/releases/latest/download/uruntime-appimage-dwarfs-$ARCH"

# Prepare AppDir
mkdir -p ./AppDir
cd ./AppDir
cp /usr/share/applications/io.github.benjamimgois.goverlay.desktop ./
cp /usr/share/icons/hicolor/256x256/apps/goverlay.png ./
cp /usr/share/icons/hicolor/256x256/apps/goverlay.png ./.DirIcon

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
wget --retry-connrefused --tries=30 "$URUNTIME" -O ./uruntime
chmod +x ./uruntime

# Add udpate info to runtime
echo "Adding update information \"$UPINFO\" to runtime..."
./uruntime --appimage-addupdinfo "$UPINFO"

echo "Generating AppImage..."
./uruntime --appimage-mkdwarfs -f \
	--set-owner 0 --set-group 0 \
	--no-history --no-create-timestamp \
	--compression zstd:level=22 -S24 -B32 \
	--header uruntime \
	-i ./AppDir -o GOverlay-"$VERSION"-anylinux-"$ARCH".AppImage

zsyncmake *.AppImage -u *.AppImage
echo "All Done!"
