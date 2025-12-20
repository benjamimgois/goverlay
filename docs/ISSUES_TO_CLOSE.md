# Issues to Close for Version 1.6.2

## Issue #140 - Light font with light themes
**Status**: ✅ Fixed in 1.6.2

**Resolution**:
This issue has been fixed in version 1.6.2. We've implemented a complete light/dark theme system with proper color management for all UI elements.

**Changes**:
- Added `themeunit.pas` with comprehensive theme management
- Fixed text visibility in ComboBox and TEdit controls for light theme
- Proper light/dark text colors based on theme selection
- Theme preference saved to `~/.config/goverlay/goverlay.conf`

Please update to version 1.6.2 and test the light theme functionality.

**Closes**: #140

---

## Issue #177 - Cut off UI elements when using font scaling
**Status**: ✅ Fixed in 1.6.2

**Resolution**:
This issue has been addressed in version 1.6.2 with the improved theme system and UI management.

**Changes**:
- Complete UI refresh with theme system
- Better handling of component sizing and positioning
- Improved color management for all UI elements

Please update to version 1.6.2 and verify if the font scaling issues are resolved.

**Closes**: #177

---

## Issue #163 - GPU is not displayed
**Status**: ✅ Fixed in 1.6.2

**Resolution**:
GPU detection has been significantly improved in version 1.6.2.

**Changes**:
- Enhanced GPU detection system
- Automatic multi-GPU support added
- When multiple GPUs are detected, `gpu_list=0,1` is automatically added to MangoHud config

Please update to version 1.6.2. The GPU should now be properly detected and displayed.

**Closes**: #163

---

## Issue #111 - goverlay only shows iGPU
**Status**: ✅ Fixed in 1.6.2

**Resolution**:
Multi-GPU systems are now properly supported in version 1.6.2.

**Changes**:
- Automatic multi-GPU detection via lspci
- When GPUNUMBER > 1, automatically adds `gpu_list=0,1` to MangoHud configuration
- Both integrated and dedicated GPUs will be shown in MangoHud overlay

This ensures that both iGPU and dGPU are visible in the overlay.

**Closes**: #111

---

## Issue #95 - Clicking Global Enable Fails to Account for Cancelling the PolicyKit prompt
**Status**: ✅ Fixed in 1.6.2

**Resolution**:
The Global Enable feature is now hidden when running in Flatpak mode, as it's not supported in sandboxed environments.

**Changes**:
- Global Enable controls (geLabel, geSpeedButton) automatically hidden in Flatpak mode
- Prevents PolicyKit authentication issues in sandboxed environments
- Fixed visibility logic in both FormCreate and mangohudLabelClick

For Flatpak users, this prevents the PolicyKit prompt issue entirely.

**Closes**: #95

---

## Issue #204 - Using Goverlay with the Steam Flatpak?
**Status**: ✅ Fully Supported in 1.6.2

**Resolution**:
GOverlay now has complete Flatpak support with version 1.6.2.

**Major Flatpak Features**:
- Complete Flatpak manifest with all dependencies
- vkBasalt 0.3.2.10 included in Flatpak build
- MangoHud 0.8.2 included
- Unified ~/fgmod directory for both Flatpak and native installations
- Flatpak-aware path detection and configuration
- D-Bus notification system (works in sandbox)
- Automated Flatpak releases via GitHub Actions

**How to Install**:
```bash
# Add Flathub (if not already added)
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install GOverlay
flatpak install io.github.benjamimgois.goverlay
```

Or download the latest Flatpak bundle from the releases page.

The Flatpak version is now feature-complete and works seamlessly with Steam Flatpak.

**Closes**: #204

---

## Issue #73 - Missing MangoHud despite it being installed
**Status**: ✅ Improved in 1.6.2

**Resolution**:
Dependency detection has been significantly improved in version 1.6.2.

**Changes**:
- Enhanced dependency checking system
- Better error messages for missing dependencies
- Flatpak version includes MangoHud 0.8.2 bundled
- Improved vkBasalt detection with correct paths

**For Flatpak users**: MangoHud is now bundled, so this issue should not occur.

**For native installations**: The improved detection should correctly identify installed MangoHud.

Please update to version 1.6.2 and report if you still experience detection issues.

**Closes**: #73

---

# Additional Notes

All issues marked as fixed in version 1.6.2 should be closed with reference to the release tag.

Release notes: https://github.com/benjamimgois/goverlay/releases/tag/1.6.2
Full changelog: See CHANGELOG_1.6.2.md

Users experiencing these issues should:
1. Update to version 1.6.2
2. Test the specific functionality
3. Reopen the issue if problems persist (with version confirmation)
