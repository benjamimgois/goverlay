#!/bin/bash
set -e

VERSION=$1
if [ -z "$VERSION" ]; then
  echo "Usage: $0 <version>"
  exit 1
fi

# Ensure version starts with a digit for package managers (e.g. debian and rpm)
if [[ ! "$VERSION" =~ ^[0-9] ]]; then
  VERSION="0.0.0.$VERSION"
fi
# Replace any hyphens in version with dots for RPM compatibility
VERSION="${VERSION//-/.}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

RPMBUILD_DIR="$PROJECT_ROOT/rpmbuild"
rm -rf "$RPMBUILD_DIR"
mkdir -p "$RPMBUILD_DIR"/{SOURCES,SPECS,BUILD,RPMS,SRPMS}

# Create source tarball
TARBALL_NAME="goverlay-$VERSION"
TARBALL_FILE="$RPMBUILD_DIR/SOURCES/$TARBALL_NAME.tar.gz"

echo "Creating source tarball..."
tar --exclude-vcs --exclude="./build_deb" --exclude="./rpmbuild" --exclude="./dist" -czf "$TARBALL_FILE" -C "$PROJECT_ROOT" --transform "s/^\./$TARBALL_NAME/" .

# Prepare spec file
SPEC_FILE="$RPMBUILD_DIR/SPECS/goverlay.spec"
sed "s/VERSION_PLACEHOLDER/$VERSION/g" "$SCRIPT_DIR/goverlay.spec" > "$SPEC_FILE"

# Build RPM
echo "Building RPM package..."
rpmbuild --define "_topdir $RPMBUILD_DIR" -bb "$SPEC_FILE" --nodeps

# Copy output RPM to project root
find "$RPMBUILD_DIR/RPMS" -type f -name "*.rpm" -exec cp {} "$PROJECT_ROOT" \;

echo "RPM package created successfully."
