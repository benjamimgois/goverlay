#!/bin/bash
# Workaround script for lazbuild 4.4 thread creation bug on Arch Linux
# Issue: lazbuild fails with "Failed to create new thread" error
#
# This script provides multiple methods to build Goverlay:

set -e

echo "=== Goverlay Build Workaround Script ==="
echo ""
echo "Choose build method:"
echo "  1) Build using Flatpak (recommended)"
echo "  2) Try building with systemd-run (may not work)"
echo "  3) Report bug to Arch Linux maintainers"
echo ""
read -p "Enter choice [1-3]: " choice

case $choice in
    1)
        echo "Building via Flatpak..."
        if [ ! -f "./build-flatpak.sh" ]; then
            echo "Error: build-flatpak.sh not found"
            exit 1
        fi
        chmod +x ./build-flatpak.sh
        ./build-flatpak.sh
        echo ""
        echo "Build complete! Install with:"
        echo "  flatpak install --user ./goverlay.flatpak"
        ;;
    2)
        echo "Attempting build with systemd-run..."
        echo "Note: This may fail due to lazbuild bug in Arch Linux package"
        systemd-run --user --scope -p TasksMax=infinity lazbuild -B goverlay.lpi --bm=Release
        if [ $? -eq 0 ]; then
            echo "Build successful!"
            ./goverlay
        else
            echo ""
            echo "Build failed. The lazbuild 4.4-1.1 package has a known bug."
            echo "Please use option 1 (Flatpak) or report the bug (option 3)."
        fi
        ;;
    3)
        echo ""
        echo "=== Bug Report Information ==="
        echo ""
        echo "Package: lazarus 4.4-1.1"
        echo "Bug: lazbuild fails with 'Failed to create new thread' (EThread)"
        echo ""
        echo "Reproduction steps:"
        echo "  1. Install lazarus package from Arch repos"
        echo "  2. Try to build any Lazarus project with lazbuild"
        echo "  3. Error occurs: Exception at 0x445F86: EThread: Failed to create new thread"
        echo ""
        echo "Expected: lazbuild should compile projects successfully"
        echo "Actual: lazbuild crashes with thread creation error"
        echo ""
        echo "System info:"
        echo "  Lazarus version: $(lazbuild --version 2>/dev/null | head -1)"
        echo "  FPC version: $(fpc -iV)"
        echo "  Kernel: $(uname -r)"
        echo ""
        echo "Possible cause: Package built without proper thread support or LTO issue"
        echo ""
        echo "Please report this to:"
        echo "  - Arch Linux bug tracker: https://bugs.archlinux.org/"
        echo "  - Package maintainer via 'pacman -Si lazarus | grep Mantenedor'"
        echo ""
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac
