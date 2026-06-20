#!/bin/bash
set -e

VERSION=$1
if [ -z "$VERSION" ]; then
  echo "Usage: $0 <version>"
  exit 1
fi

# Ensure version starts with a digit for package managers (e.g. debian and rpm)
if [[ ! "$VERSION" =~ ^[0-9] ]]; then
  VERSION="0.0.0-$VERSION"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

BUILD_DIR="$PROJECT_ROOT/build_deb"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/DEBIAN"

# Install files using Makefile
cd "$PROJECT_ROOT"
make prefix=/usr libexecdir=/lib DESTDIR="$BUILD_DIR" install

# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
  DEB_ARCH="amd64"
elif [ "$ARCH" = "aarch64" ]; then
  DEB_ARCH="arm64"
else
  DEB_ARCH="$ARCH"
fi

# Copy control and substitute version and architecture
if [ "$ARCH" = "aarch64" ]; then
  sed -e "s/VERSION_PLACEHOLDER/$VERSION/g" \
      -e "s/Architecture: amd64/Architecture: $DEB_ARCH/g" \
      -e "s/libqt6pas6 (>= 6.2.0)/libqt5pas1/g" \
      "$SCRIPT_DIR/control" > "$BUILD_DIR/DEBIAN/control"
else
  sed -e "s/VERSION_PLACEHOLDER/$VERSION/g" \
      -e "s/Architecture: amd64/Architecture: $DEB_ARCH/g" \
      "$SCRIPT_DIR/control" > "$BUILD_DIR/DEBIAN/control"
fi

# Set correct permissions
chmod -R g-w "$BUILD_DIR"
chmod 755 "$BUILD_DIR/DEBIAN"
chmod 644 "$BUILD_DIR/DEBIAN/control"

# Build package
dpkg-deb --build "$BUILD_DIR" "goverlay_${VERSION}_${DEB_ARCH}.deb"

echo "Debian package created: goverlay_${VERSION}_${DEB_ARCH}.deb"
