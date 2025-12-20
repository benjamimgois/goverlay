# Changelog - Version 1.6.3

All notable changes made since version 1.6.2

## Steam Deck Preset System

### New Features
- **Steam Deck Preset Saving**: Added complete preset management system for MangoHud configurations
  - 4 preset slots accessible via "Save As" menu
  - Each preset saves current MangoHud configuration to `~/.config/MangoHud/presets.conf`
  - Format: `[preset N]` header followed by complete configuration
  - Automatic replacement of existing presets with same number
  - D-Bus notifications for save confirmations (Flatpak compatible)
  - Perfect for quickly switching between different Steam Deck performance profiles

### Implementation Details
- Added `SaveMangoHudPreset` procedure to handle preset file operations
- Smart preset replacement logic prevents duplicate entries
- Preserves existing presets when adding new ones
- Creates presets.conf file automatically if it doesn't exist
- All 4 menu items properly connected to event handlers

## MangoHud Configuration

### Display Improvements
- **Distro Info Formatting**: Added visual separators for distro information display
  - Each distro info line (distro name and kernel version) now has a `-` separator before it
  - Uses `custom_text=-` entries in configuration file
  - Improves visual organization of system information in the HUD
  - Example output format:
    ```
    custom_text=-
    exec=cat ~/.config/goverlay/distro
    custom_text=-
    exec=uname -r
    ```

## UI Improvements

### Menu Context Awareness
- **Dynamic Menu Visibility**: Menu items now show/hide based on active tab
  - "Save As" menu item only visible in MangoHud tab (hidden in vkBasalt/OptiScaler tabs)
  - "Blacklist Apps" menu item only visible in MangoHud tab (hidden in vkBasalt/OptiScaler tabs)
  - Prevents confusion by showing only relevant options for each overlay tool

### Panel Styling
- Removed borders from `goverlaybarPanel` in both light and dark themes
  - Cleaner, more modern appearance
  - Consistent styling across theme modes

## Bug Fixes

### vkBasalt Detection
- **Improved Library Detection**: Enhanced vkBasalt detection to check for JSON file in addition to library
  - Now checks for both `libvkbasalt.so` library and `vkbasalt.json` configuration
  - Better compatibility across different vkBasalt installation methods
  - Fixes false "vkBasalt missing" warnings on some systems

### Configuration Fixes
- **FPS Cap Offset**: Fixed FPS cap offset calculation
  - Corrected offset calculation logic for frame rate limiting
  - More accurate FPS cap values
- **Syntax Error**: Fixed missing parenthesis in configuration code

## Code Quality

### Consistency Improvements
- All Steam Deck preset notifications use unified D-Bus notification system
- Follows same notification pattern as rest of application
- Better Flatpak compatibility and sandbox support

---

## Summary Statistics
- **Total commits since 1.6.2**: 6
- **Major features added**: 1 (Steam Deck Preset System)
- **MangoHud improvements**: 1 (Distro info formatting)
- **UI improvements**: 2 (Menu context awareness, Panel styling)
- **Bug fixes**: 3 (vkBasalt detection, FPS cap offset, syntax error)
- **New files created**: 0
- **Files modified**: 2 (overlayunit.pas, overlayunit.lfm)

## Files Changed
- `overlayunit.pas`: Added Steam Deck preset functionality, menu context logic, distro info formatting
- `overlayunit.lfm`: Added 4 Steam Deck preset menu items with event handlers
