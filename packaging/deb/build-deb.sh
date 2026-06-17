#!/bin/bash
set -e

VERSION=$1
if [ -z "$VERSION" ]; then
  echo "Usage: $0 <version>"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

BUILD_DIR="$PROJECT_ROOT/build_deb"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/DEBIAN"

# Install files using Makefile
cd "$PROJECT_ROOT"
make prefix=/usr libexecdir=/lib DESTDIR="$BUILD_DIR" install

# Copy control and substitute version
sed "s/VERSION_PLACEHOLDER/$VERSION/g" "$SCRIPT_DIR/control" > "$BUILD_DIR/DEBIAN/control"

# Set correct permissions
chmod -R g-w "$BUILD_DIR"
chmod 755 "$BUILD_DIR/DEBIAN"
chmod 644 "$BUILD_DIR/DEBIAN/control"

# Build package
dpkg-deb --build "$BUILD_DIR" "goverlay_${VERSION}_amd64.deb"

echo "Debian package created: goverlay_${VERSION}_amd64.deb"
