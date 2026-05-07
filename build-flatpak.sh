#!/bin/bash
# Script to build and test Goverlay Flatpak package

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Goverlay Flatpak Build Script ===${NC}\n"

# Check dependencies
echo -e "${YELLOW}Checking dependencies...${NC}"

if ! command -v flatpak &> /dev/null; then
    echo -e "${RED}Error: Flatpak is not installed${NC}"
    echo "Install with: sudo pacman -S flatpak"
    exit 1
fi

if ! command -v flatpak-builder &> /dev/null; then
    echo -e "${RED}Error: flatpak-builder is not installed${NC}"
    echo "Install with: sudo pacman -S flatpak-builder"
    exit 1
fi

echo -e "${GREEN}✓ Flatpak installed: $(flatpak --version)${NC}"

# Check runtime
echo -e "\n${YELLOW}Checking Flatpak runtime...${NC}"
if ! flatpak list --runtime | grep -q "org.kde.Platform.*6.10"; then
    echo -e "${YELLOW}Runtime org.kde.Platform 6.10 not found${NC}"
    echo "Installing runtime..."
    flatpak install -y flathub org.kde.Platform//6.10 org.kde.Sdk//6.10
else
    echo -e "${GREEN}✓ Runtime org.kde.Platform 6.10 already installed${NC}"
fi

# Check FreePascal extension
# Note: KDE SDK 6.10 is based on Freedesktop SDK 24.08, so we need freepascal//24.08
echo -e "\n${YELLOW}Checking FreePascal extension...${NC}"
if ! flatpak list --runtime | grep -q "org.freedesktop.Sdk.Extension.freepascal.*24.08"; then
    echo -e "${YELLOW}Extension org.freedesktop.Sdk.Extension.freepascal 24.08 not found${NC}"
    echo "Installing FreePascal extension (compatible with KDE SDK 6.10)..."
    flatpak install -y flathub org.freedesktop.Sdk.Extension.freepascal//24.08
else
    echo -e "${GREEN}✓ Extension org.freedesktop.Sdk.Extension.freepascal 24.08 already installed${NC}"
fi

# Check Qt WebEngine base
echo -e "\n${YELLOW}Checking Qt WebEngine base...${NC}"
if ! flatpak list --runtime | grep -q "io.qt.qtwebengine.BaseApp.*6.10"; then
    echo -e "${YELLOW}Base io.qt.qtwebengine.BaseApp 6.10 not found${NC}"
    echo "Installing Qt WebEngine base..."
    flatpak install -y flathub io.qt.qtwebengine.BaseApp//6.10
else
    echo -e "${GREEN}✓ Base io.qt.qtwebengine.BaseApp 6.10 already installed${NC}"
fi

# Create build directory
BUILD_DIR="flatpak-build"
REPO_DIR="flatpak-repo"

echo -e "\n${YELLOW}Preparing build directories...${NC}"
rm -rf "$BUILD_DIR" "$REPO_DIR"
mkdir -p "$BUILD_DIR" "$REPO_DIR"

# Build the Flatpak
echo -e "\n${GREEN}=== Starting Flatpak build ===${NC}\n"

# Note: Some checksums in the manifest may be incorrect and will need to be updated
# For quick testing, we can use --disable-download-validation but this is not recommended for production

flatpak-builder \
    --force-clean \
    --repo="$REPO_DIR" \
    --disable-rofiles-fuse \
    --ccache \
    --state-dir=".flatpak-builder" \
    "$BUILD_DIR" \
    io.github.benjamimgois.goverlay.yml \
    || {
        echo -e "\n${RED}Flatpak build error${NC}"
        echo -e "${YELLOW}If the error is related to checksums, you will need to update them in the manifest${NC}"
        echo -e "${YELLOW}To calculate checksums: sha256sum <file>${NC}"
        exit 1
    }

echo -e "\n${GREEN}✓ Build completed successfully!${NC}"

# Extract GVERSION and GCHANNEL from overlayunit.pas
echo -e "\n${YELLOW}Detecting version and channel...${NC}"
GVERSION=$(grep "GVERSION := " overlayunit.pas | head -1 | sed "s/.*GVERSION := '\(.*\)';.*/\1/")
GCHANNEL=$(grep "GCHANNEL := " overlayunit.pas | head -1 | sed "s/.*GCHANNEL := '\(.*\)';.*/\1/")

if [ -z "$GVERSION" ] || [ -z "$GCHANNEL" ]; then
    echo -e "${RED}Error: Could not detect GVERSION or GCHANNEL${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Version detected: ${GVERSION}${NC}"
echo -e "${GREEN}✓ Channel detected: ${GCHANNEL}${NC}"

# Create filename in format goverlay_VERSION_CHANNEL.flatpak
FLATPAK_FILE="goverlay_${GVERSION}_${GCHANNEL}.flatpak"

# Create the .flatpak bundle
echo -e "\n${YELLOW}Creating file ${FLATPAK_FILE}...${NC}"
flatpak build-bundle "$REPO_DIR" "$FLATPAK_FILE" io.github.benjamimgois.goverlay || {
    echo -e "\n${RED}Error creating Flatpak bundle${NC}"
    exit 1
}

if [ -f "$FLATPAK_FILE" ]; then
    FILESIZE=$(ls -lh "$FLATPAK_FILE" | awk '{print $5}')
    echo -e "${GREEN}✓ File ${FLATPAK_FILE} created successfully! (${FILESIZE})${NC}"
else
    echo -e "${RED}Error: File ${FLATPAK_FILE} was not created${NC}"
    exit 1
fi

# Install locally
echo -e "\n${YELLOW}Do you want to install the Flatpak locally? (y/N)${NC}"
read -r -n 1 INSTALL
echo

if [[ $INSTALL =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Installing Goverlay...${NC}"

    # Install from bundle file
    flatpak --user install -y "$FLATPAK_FILE"

    echo -e "\n${GREEN}✓ Goverlay installed successfully!${NC}"
    echo -e "${GREEN}Run with: flatpak run io.github.benjamimgois.goverlay${NC}"
fi

echo -e "\n${GREEN}=== Process completed ===${NC}"
echo -e "\nFile created: ${GREEN}${FLATPAK_FILE}${NC}"
echo -e "\nTo install manually:"
echo -e "  flatpak install ${FLATPAK_FILE}"
echo -e "\nTo uninstall:"
echo -e "  flatpak uninstall io.github.benjamimgois.goverlay"
