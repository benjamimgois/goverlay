# GOverlay 1.6.4 - Changelog

**Release Date:** 2025-12-14
**Repository:** https://github.com/benjamimgois/goverlay
**Previous Version:** 1.6.3

---

## Major Features

### FSR4 Variant Management System

**What it does:**
Implements a complete dual-version FSR4 support system allowing users to switch between FP8 (floating point 8-bit) and INT8 (integer 8-bit) variants of the AMD FidelityFX Super Resolution 4 upscaler.

**Why it matters:**
Different games and hardware configurations may benefit from different FSR4 variants. The FP8 version offers the latest features and potentially better quality, while the INT8 version (4.0.2) provides better compatibility and performance on certain hardware.

**How it works:**
- **Automatic Setup**: When updating OptiScaler, GOverlay automatically creates two folders (`FSR4_LATEST` and `FSR4_INT8`) and downloads both variants
- **Easy Switching**: Users select their preferred variant from a dropdown menu in the OptiScaler tab
- **Smart Persistence**: Selection is saved to `goverlay.vars` and automatically restored on next startup
- **Seamless Integration**: DLL files are automatically swapped when saving configuration

**User Interface:**
- New dropdown menu with two options:
  - **Latest (FP8)** - Floating point 8-bit precision (latest features)
  - **4.0.2 (INT8)** - Integer 8-bit precision (better compatibility)
- Version label displays current FSR4 variant in use

**Technical Details:**
- Folders created: `~/fgmod/FSR4_LATEST/` and `~/fgmod/FSR4_INT8/`
- INT8 variant downloaded from: `https://github.com/xXJSONDeruloXx/OptiScaler-Bleeding-Edge/releases/download/amd-fsr-r-int8/`
- Version tracking stored in: `~/fgmod/goverlay.vars`
- Automatic restoration: Reads `fsrversion=` line on startup and sets UI accordingly

### Implementation Files Modified:
- **optiscaler_update.pas**:
  - Added `FFsrVersionComboBox` property to `TOptiscalerTab` class
  - `UpdateButtonClick`: Creates FSR4 folders and downloads INT8 variant after OptiScaler installation
  - `LoadVersionsFromFile`: Reads `fsrversion` from `goverlay.vars` on startup
  - Sets ComboBox ItemIndex based on saved version

- **overlayunit.pas**:
  - Added `fsrversionComboBox` UI component
  - `saveBitBtnClick`: Copies appropriate DLL based on user selection
  - Updates `goverlay.vars` with `fsrversion=4.0.2 (INT8)` when INT8 is selected
  - `FormCreate`: Assigns ComboBox to `FOptiscalerUpdate`

- **overlayunit.lfm**:
  - Added UI controls for FSR4 version selection

---

## Bug Fixes

### MangoHud FPS Limit Offset - Special Case for Zero

**Issue:** When using the FPS limit offset feature, a value of `0` (unlimited) was being affected by the offset calculation, resulting in incorrect values like `-5`, `-10`, etc.

**Fix:** Added special case handling to preserve `0` (unlimited) values when applying FPS offset.

**Technical Details:**
- Added `TempFPS` variable to store intermediate calculation
- Check: `if TempFPS <> 0 then TempFPS := TempFPS + offsetSpinedit.Value`
- Applies to both:
  - FPS limit checkbox selection (`fpslimcheckgroup`)
  - Config file loading/saving

**Impact:**
- Users can now safely use FPS offset without affecting unlimited (0) FPS settings
- Preserves intended behavior for games that support unlimited framerate

**Credit:** Contributed by [@LuanVSO](https://github.com/LuanVSO) via PR #222

**Files Modified:**
- `overlayunit.pas` (lines 2980-2986, 3757-3761)

---

## Summary Statistics

- **Total commits since 1.6.3**: 3
- **Merge commits**: 1 (PR #222)
- **Major features added**: 1 (FSR4 Variant Management)
- **Bug fixes**: 1 (FPS limit offset zero handling)
- **New files created**: 0
- **Files modified**: 3 (overlayunit.pas, overlayunit.lfm, optiscaler_update.pas)
- **Contributors**: 2 (Benjamim Gois, Luan Vitor Simião oliveira)

---

## Files Changed

### optiscaler_update.pas
- Added `FFsrVersionComboBox` field and property
- Updated `LoadVersionsFromFile` to read and apply FSR4 version from goverlay.vars
- Updated `UpdateButtonClick` to create FSR4 variant folders and download INT8 version

### overlayunit.pas
- Added `fsrversionComboBox` component
- Added FSR4 variant switching logic in `saveBitBtnClick`
- Fixed FPS limit offset zero handling in multiple locations
- Version bumped to 1.6.4-git

### overlayunit.lfm
- Added UI controls for FSR4 version selection

---

## Upgrade Notes

### For Users

**FSR4 Variant System:**
1. Update OptiScaler using the "Update" button in the OptiScaler tab
2. Both FSR4 variants will be automatically downloaded and set up
3. Choose your preferred variant from the new dropdown menu
4. Your selection will be saved and remembered across restarts

**FPS Limit Offset:**
- No action required - the fix automatically handles zero (unlimited) FPS values correctly

### For Developers

**New Dependencies:**
- None - all functionality uses existing libraries

**API Changes:**
- New property: `TOptiscalerTab.FsrVersionComboBox`
- New file format: `goverlay.vars` now supports `fsrversion=` line
- New folders: `~/fgmod/FSR4_LATEST/` and `~/fgmod/FSR4_INT8/`

---

## Known Issues

None reported in this release.

---

## Contributors

- **Benjamim Gois** (@benjamimgois) - FSR4 variant management system
- **Luan Vitor Simião oliveira** (@LuanVSO) - FPS limit offset zero handling fix
- **Claude Sonnet 4.5** - Implementation assistance

---

## Full Commit History

```
777943d5 Merge pull request #222 from LuanVSO/main (Benjamim Gois)
dbcbf0e1 Add FSR4 variant management system (Benjamim Gois)
c5d4d365 special case 0 fps_limit (Luan Vitor Simião oliveira)
```

---

**Previous Version:** [CHANGELOG_1.6.3.md](CHANGELOG_1.6.3.md)
