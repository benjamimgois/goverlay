# Button Icons for Goverlay

This directory contains icons for the main buttons in Goverlay's interface.

## Icon Files

All icons are available in three sizes: 16x16, 24x24, and 32x32 pixels.

### Available Icons

| Icon File | Description | Suggested Use |
|-----------|-------------|---------------|
| `save.svg` / `save.png` | Floppy disk icon | Save configuration buttons |
| `test.svg` / `test.png` | Play button | Test/launch buttons (vkcube, demos) |
| `update.svg` / `update.png` | Refresh/sync arrows | Update/check for updates buttons |
| `copy.svg` / `copy.png` | Clipboard copy | Copy to clipboard buttons |
| `download.svg` / `download.png` | Download arrow | Download/install buttons |
| `folder.svg` / `folder.png` | Folder icon | Browse folder/log path buttons |
| `help.svg` / `help.png` | Question mark | Help/how-to buttons |
| `check.svg` / `check.png` | Check mark | Verify/check status buttons |

## Button Mapping

### Main Buttons (from overlayunit.pas)

- **saveBitBtn** → `save.png` - Save MangoHud configuration
- **copyBitBtn** → `copy.png` - Copy OptiScaler command to clipboard
- **updateBitBtn** → `update.png` - Update OptiScaler
- **checkupdBitBtn** → `check.png` - Check for OptiScaler updates
- **gupdateBitBtn** → `download.png` - Update Goverlay
- **howtoBitBtn** → `help.png` - How to use OptiScaler
- **logfolderBitBtn** → `folder.png` - Browse log folder
- **reshaderefreshBitBtn** → `download.png` - Download ReShade shaders
- **blacklistBitBtn** → Similar buttons (settings icon could be added)

### Preset Buttons
- **fullBitBtn**, **basicBitBtn**, **fpsonlyBitBtn**, etc. → Could use preset-specific icons

## Usage in Lazarus

To add these icons to buttons in Lazarus IDE:

1. Open the form in Lazarus IDE
2. Select the ImageList component (already exists: `iconsImageList`)
3. Add the PNG icons from the appropriate size folder (24x24 recommended)
4. For each button:
   - Set `Images` property to the ImageList
   - Set `ImageIndex` property to the correct icon index
   - Optionally set `Layout` to position icon relative to text

## Style Guide

- Icons use a minimalist line style (2px stroke)
- All icons are designed to work well on dark backgrounds
- SVG source files are provided for easy modification
- Colors can be adjusted in the SVG files if needed

## Adding New Icons

To add new icons:

1. Create/download an SVG file and place it in this directory
2. Run the conversion script:
   ```bash
   cd data/icons/buttons
   for size in 16 24 32; do
     magick -background none -density 300 newicon.svg -resize ${size}x${size} ${size}x${size}/newicon.png
   done
   ```
3. Add the PNG to the ImageList in Lazarus
4. Update this README with the new icon

## Credits

Icons based on the Lucide icon set style (MIT License compatible).
