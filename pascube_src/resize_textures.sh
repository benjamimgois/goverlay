#!/bin/bash
# Script to resize all PNG textures to 128x128 with transparent padding
# Maintains aspect ratio by centering images on transparent canvas

set -e

TEXTURES_DIR="/home/benjamim/Documentos/pascube/assets/textures"
BACKUP_DIR="$TEXTURES_DIR/originals"

echo "=== Texture Resize Script ==="
echo "Target size: 128x128 pixels"
echo "Textures directory: $TEXTURES_DIR"
echo ""

# Create backup directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Creating backup directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
fi

# Change to textures directory
cd "$TEXTURES_DIR"

# Counter for processed files
PROCESSED=0

# Process each PNG file
for file in *.png; do
    # Skip if no PNG files found
    if [ "$file" = "*.png" ]; then
        echo "No PNG files found!"
        exit 1
    fi
    
    # Skip metal.png and reflection.png (they are JPEGs despite extension)
    if [ "$file" = "metal.png" ] || [ "$file" = "reflection.png" ]; then
        echo "Skipping $file (JPEG file)"
        continue
    fi
    
    # Get current dimensions
    CURRENT_SIZE=$(identify -format "%wx%h" "$file")
    
    echo "Processing: $file ($CURRENT_SIZE)"
    
    # Backup original if not already backed up
    if [ ! -f "$BACKUP_DIR/$file" ]; then
        echo "  → Backing up to: $BACKUP_DIR/$file"
        cp "$file" "$BACKUP_DIR/$file"
    else
        echo "  → Backup already exists"
    fi
    
    # Resize with transparent padding
    echo "  → Resizing to 128x128 with transparent padding"
    convert "$file" \
        -resize 128x128 \
        -background none \
        -gravity center \
        -extent 128x128 \
        "$file"
    
    # Verify new size
    NEW_SIZE=$(identify -format "%wx%h" "$file")
    echo "  ✓ New size: $NEW_SIZE"
    echo ""
    
    PROCESSED=$((PROCESSED + 1))
done

echo "=== Resize Complete ==="
echo "Processed $PROCESSED PNG files"
echo "Originals backed up to: $BACKUP_DIR"
echo ""
