#!/bin/bash
# Automated script to process contributor textures
# Finds all contributor-*.png files, resizes to 128x128, adds name overlay, renumbers sequentially

set -e

TEXTURE_DIR="."  # Current directory (assets/textures/)
SIZE=128
TEXT_COLOR="white"
TEXT_BACKGROUND="#00000099"  # Semi-transparent black
FONT_SIZE=12
TEMP_DIR=$(mktemp -d)

echo "=== Contributor Texture Processor ==="
echo "Searching for contributor-*.png files..."
echo ""

# Find all contributor-*.png files
CONTRIBUTORS=($(ls "$TEXTURE_DIR"/contributor-*.png 2>/dev/null || true))

if [ ${#CONTRIBUTORS[@]} -eq 0 ]; then
    echo "No contributor-*.png files found."
    echo ""
    echo "To use this script:"
    echo "  1. Place images named 'contributor-yourname.png' in $TEXTURE_DIR/"
    echo "  2. Run this script"
    echo "  3. Images will be processed and renumbered as contributor-1.png, contributor-2.png, etc."
    exit 0
fi

echo "Found ${#CONTRIBUTORS[@]} contributor texture(s):"
for img in "${CONTRIBUTORS[@]}"; do
    basename "$img"
done
echo ""

# Process each contributor image
counter=1
for original_file in "${CONTRIBUTORS[@]}"; do
    # Extract contributor name from filename
    # contributor-benjamim.png -> benjamim
    filename=$(basename "$original_file")
    contributor_name="${filename#contributor-}"  # Remove 'contributor-' prefix
    contributor_name="${contributor_name%.png}"   # Remove '.png' extension
    
    temp_output="$TEMP_DIR/contributor-${counter}.png"
    
    echo "[$counter/${#CONTRIBUTORS[@]}] Processing: $contributor_name"
    echo "  Input: $filename"
    echo "  Output: contributor-${counter}.png"
    
    # Process image: resize to 128x128 and add two-line text overlay
    # Line 1: "Contributor"
    # Line 2: contributor name
    magick "$original_file" \
        -resize ${SIZE}x${SIZE} \
        -background none \
        -gravity center \
        -extent ${SIZE}x${SIZE} \
        \( -size ${SIZE}x30 xc:"${TEXT_BACKGROUND}" \
           -gravity center \
           -pointsize 10 \
           -fill "${TEXT_COLOR}" \
           -font "DejaVu-Sans-Bold" \
           -annotate +0-8 "Contributor" \
           -pointsize ${FONT_SIZE} \
           -annotate +0+8 "$contributor_name" \) \
        -gravity south \
        -composite \
        "$temp_output"
    
    counter=$((counter + 1))
done

echo ""
echo "=== Finalizing ==="

# Delete all original contributor-*.png files
echo "Removing original files..."
for original_file in "${CONTRIBUTORS[@]}"; do
    rm -f "$original_file"
    echo "  ✓ Deleted: $(basename "$original_file")"
done

# Move processed files from temp to destination
echo ""
echo "Installing processed files..."
mv "$TEMP_DIR"/contributor-*.png .
for ((i=1; i<counter; i++)); do
    echo "  ✓ Created: contributor-${i}.png"
done

# Cleanup
rm -rf "$TEMP_DIR"

echo ""
echo "=== Complete ==="
echo "Processed $((counter - 1)) contributor texture(s)"
echo "Textures are ready to use in PasCube!"
