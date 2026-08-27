#!/bin/sh

set -eu

ARCH="$(uname -m)"
if [ -z "${VERSION:-}" ]; then
  if [ -n "${GITHUB_SHA:-}" ]; then
    VERSION="$(echo "$GITHUB_SHA" | cut -c 1-9)"
  else
    VERSION="nightly"
  fi
fi
export VERSION

REPO="${GITHUB_REPOSITORY:-benjamimgois/goverlay}"
REPO_OWNER="${REPO%/*}"
REPO_NAME="${REPO#*/}"

if [ -n "${TAG_NAME:-}" ]; then
  UP_TAG="latest"
else
  UP_TAG="nightly"
fi

SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"

export DESKTOP=/usr/share/applications/io.github.benjamimgois.goverlay.desktop
export ICON=/usr/share/icons/hicolor/256x256/apps/io.github.benjamimgois.goverlay.png
export DEPLOY_OPENGL=1
export DEPLOY_VULKAN=1
export UPINFO="gh-releases-zsync|${REPO_OWNER}|${REPO_NAME}|${UP_TAG}|goverlay-*-${ARCH}.AppImage.zsync"
export OUTNAME="goverlay-${VERSION}-${ARCH}.AppImage"

# ADD LIBRARIES
wget --retry-connrefused --tries=30 "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun
./quick-sharun \
	/usr/lib/goverlay        \
	/usr/lib/pascube         \
	/usr/share/goverlay      \
	/usr/lib/mangohud/*      \
	/usr/lib/libvkbasalt.so* \
	/usr/bin/vkcube          \
	/usr/bin/lspci           \
	/usr/bin/mangohud        \
	/usr/lib/libVkLayer_vksumi.so \
	/usr/bin/vksumi-toggle   \
	/usr/share/fonts/TTF/SymbolsNerdFont-Regular.ttf
mkdir -p ./AppDir/share/vulkan/implicit_layer.d
cp -v /usr/share/vulkan/implicit_layer.d/vkBasalt.json ./AppDir/share/vulkan/implicit_layer.d
cp -v /usr/share/vulkan/implicit_layer.d/vksumi.json ./AppDir/share/vulkan/implicit_layer.d
# Patch vksumi.json to use relative library path so it loads from the AppImage lib directory
sed -i 's|/usr/lib/libVkLayer_vksumi.so|libVkLayer_vksumi.so|' ./AppDir/share/vulkan/implicit_layer.d/vksumi.json

# Copy bundled assets & data so icons load inside the AppImage.
# The script may be executed from any cwd (e.g. repo root in CI),
# so resolve paths relative to the script's own directory.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
echo "[AppImageBuild] SCRIPT_DIR=$SCRIPT_DIR"
echo "[AppImageBuild] PROJECT_ROOT=$PROJECT_ROOT"

# Workaround: in some CI containers actions/checkout drops the assets/
# directory even though it is tracked. Download the PNGs directly from
# GitHub raw when the local folder is missing.
if [ ! -d "${PROJECT_ROOT}/assets" ]; then
  echo "[AppImageBuild] assets/ missing — downloading from GitHub raw..."
  RAW="https://raw.githubusercontent.com/benjamimgois/goverlay/main/assets/icons"
  mkdir -p ./AppDir/bin/assets/icons
  for f in mango-inactive.png mango-active.png scale-up2.png scale-up2-active.png global-white.png; do
    wget --retry-connrefused --tries=10 -q "${RAW}/${f}" -O "./AppDir/bin/assets/icons/${f}" && echo "[AppImageBuild] Downloaded ${f}" || echo "[AppImageBuild] FAILED to download ${f}"
  done
fi

if [ -d "${PROJECT_ROOT}/assets" ]; then
  echo "[AppImageBuild] Copying assets from ${PROJECT_ROOT}/assets to ./AppDir/bin/"
  cp -rv "${PROJECT_ROOT}/assets" ./AppDir/bin/
else
  echo "[AppImageBuild] WARNING: ${PROJECT_ROOT}/assets does not exist!"
fi
if [ -d "${PROJECT_ROOT}/data" ]; then
  echo "[AppImageBuild] Copying data from ${PROJECT_ROOT}/data to ./AppDir/bin/"
  cp -rv "${PROJECT_ROOT}/data" ./AppDir/bin/
else
  echo "[AppImageBuild] WARNING: ${PROJECT_ROOT}/data does not exist!"
fi
if [ -d "${PROJECT_ROOT}/languages" ]; then
  echo "[AppImageBuild] Copying languages from ${PROJECT_ROOT}/languages to ./AppDir/bin/"
  cp -rv "${PROJECT_ROOT}/languages" ./AppDir/bin/
else
  echo "[AppImageBuild] WARNING: ${PROJECT_ROOT}/languages does not exist!"
fi
# Copy unwrapped bgmod and bgmod-uninstaller binaries directly to AppDir/lib
mkdir -p ./AppDir/lib
cp -pf /usr/lib/bgmod ./AppDir/lib/bgmod
cp -pf /usr/lib/bgmod-uninstaller ./AppDir/lib/bgmod-uninstaller

echo "[AppImageBuild] ls AppDir/bin:"
ls -la ./AppDir/bin/

# make appimage with uruntime
./quick-sharun --make-appimage
