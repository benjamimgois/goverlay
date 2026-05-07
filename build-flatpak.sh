#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# GOverlay Flatpak Bundle Builder
# =============================================================================
# This script builds a self-contained .flatpak bundle from the current source
# tree using io.github.benjamimgois.goverlay.local.yml.
#
# Usage:
#   ./build-flatpak.sh [OPTIONS]
#
# Options:
#   --clean           Force clean build (remove previous build dirs)
#   --skip-deps       Skip checking/installing Flatpak dependencies
#   --version VER     Override auto-detected version
#   --output PATH     Custom output path for the .flatpak file
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_MANIFEST="${SCRIPT_DIR}/io.github.benjamimgois.goverlay.local.yml"
BUILD_DIR="${SCRIPT_DIR}/flatpak-build"
REPO_DIR="${SCRIPT_DIR}/flatpak-repo"
STATE_DIR="${SCRIPT_DIR}/.flatpak-builder"

CLEAN=0
SKIP_DEPS=0
OVERRIDE_VERSION=""
OUTPUT_PATH=""

# -----------------------------------------------------------------------------
# Parse arguments
# -----------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --clean) CLEAN=1; shift ;;
    --skip-deps) SKIP_DEPS=1; shift ;;
    --version) OVERRIDE_VERSION="$2"; shift 2 ;;
    --output) OUTPUT_PATH="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# -----------------------------------------------------------------------------
# Detect version from source
# -----------------------------------------------------------------------------
if [[ -n "$OVERRIDE_VERSION" ]]; then
  VERSION="$OVERRIDE_VERSION"
else
  VERSION="$(grep -oP "GVERSION\s*:=\s*'\K[^']+" "${SCRIPT_DIR}/overlayunit.pas" 2>/dev/null || true)"
  if [[ -z "$VERSION" ]]; then
    VERSION="$(git -C "$SCRIPT_DIR" describe --tags --always 2>/dev/null || echo 'dev')"
  fi
fi

echo "========================================"
echo "  GOverlay Flatpak Bundle Builder"
echo "  Version: ${VERSION}"
echo "========================================"

# -----------------------------------------------------------------------------
# Verify manifest exists
# -----------------------------------------------------------------------------
if [[ ! -f "$LOCAL_MANIFEST" ]]; then
  echo "ERROR: Local manifest not found: $LOCAL_MANIFEST"
  exit 1
fi

# -----------------------------------------------------------------------------
# Dependency checks
# -----------------------------------------------------------------------------
if [[ "$SKIP_DEPS" -eq 0 ]]; then
  echo "[1/5] Checking dependencies..."

  if ! command -v flatpak &>/dev/null; then
    echo "ERROR: flatpak is not installed."
    echo "Install it with: sudo apt install flatpak  (Debian/Ubuntu)"
    echo "                 sudo pacman -S flatpak     (Arch)"
    exit 1
  fi

  if ! command -v flatpak-builder &>/dev/null; then
    echo "ERROR: flatpak-builder is not installed."
    echo "Install it with: sudo apt install flatpak-builder"
    exit 1
  fi

  # Ensure flathub remote exists
  if ! flatpak remote-list --user | grep -q flathub; then
    if ! flatpak remote-list | grep -q flathub; then
      echo "[INFO] Adding Flathub remote..."
      sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    fi
  fi

  # Required runtimes/SDKs
  REQUIRED_SDKS=(
    "org.kde.Platform/x86_64/6.10"
    "org.kde.Sdk/x86_64/6.10"
    "io.qt.qtwebengine.BaseApp/x86_64/6.10"
    "org.freedesktop.Sdk.Extension.freepascal/x86_64/25.08"
  )

  for sdk in "${REQUIRED_SDKS[@]}"; do
    if ! flatpak list --runtime | grep -qF "$sdk"; then
      echo "[INFO] Installing missing SDK/Runtime: $sdk"
      # Try user install first (no sudo needed), fallback to system
      flatpak install --user -y flathub "$sdk" 2>/dev/null || \
        sudo flatpak install -y flathub "$sdk" 2>/dev/null || {
          echo "ERROR: Failed to install $sdk"
          exit 1
        }
    else
      echo "[OK] $sdk is installed"
    fi
  done
else
  echo "[1/5] Skipping dependency checks (--skip-deps)"
fi

# -----------------------------------------------------------------------------
# Clean previous build if requested
# -----------------------------------------------------------------------------
if [[ "$CLEAN" -eq 1 ]]; then
  echo "[2/5] Cleaning previous build directories..."
  rm -rf "$BUILD_DIR" "$REPO_DIR" "$STATE_DIR"
else
  echo "[2/5] Using existing build state (use --clean to wipe)"
fi

# -----------------------------------------------------------------------------
# Build with flatpak-builder
# -----------------------------------------------------------------------------
echo "[3/5] Building Flatpak..."
flatpak-builder \
  --force-clean \
  --repo="$REPO_DIR" \
  --disable-rofiles-fuse \
  --ccache \
  --state-dir="$STATE_DIR" \
  "$BUILD_DIR" \
  "$LOCAL_MANIFEST"

# -----------------------------------------------------------------------------
# Create bundle
# -----------------------------------------------------------------------------
echo "[4/5] Creating Flatpak bundle..."

if [[ -z "$OUTPUT_PATH" ]]; then
  OUTPUT_PATH="${SCRIPT_DIR}/goverlay-${VERSION}-x86_64.flatpak"
fi

flatpak build-bundle \
  "$REPO_DIR" \
  "$OUTPUT_PATH" \
  io.github.benjamimgois.goverlay

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
echo "[5/5] Done!"
echo ""
echo "  Bundle: $OUTPUT_PATH"
echo "  Size:   $(du -h "$OUTPUT_PATH" | cut -f1)"
echo ""
echo "Install with:"
echo "  flatpak install --user \"$OUTPUT_PATH\""
echo ""
echo "Or distribute via GitHub Releases by attaching this file."
