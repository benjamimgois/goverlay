# GOverlay 1.7.1 Changelog

**Release Date:** January 14, 2026

## New Features

### MangoHud Configuration
- **Added:** `fexstatsCheckBox` support to enable/disable `fex_stats` option in MangoHud configuration
  - Automatically loads checkbox state when `fex_stats` is present in config file
  - Saves `fex_stats` line when checkbox is checked
- **Improved:** `timeCheckBox` now correctly adds both `time` and `time_no_label` to MangoHud configuration
  - Replaced legacy `time#` configuration with proper `time` and `time_no_label` options
  - Updated load logic to recognize both `time` and `time#` for backward compatibility
- **Fixed:** `fpsonlyBitBtn` now correctly writes only `fps_only` to MangoHud configuration
  - Button now clears all UI checkboxes and creates minimal config with only `fps_only` line
  - Added save notification when FPS-only mode is activated

### OptiScaler
- **Added:** `spoofCheckBox` support to modify `Dxgi=` parameter in OptiScaler.ini
  - Allows users to spoof GPU vendor information for compatibility
- **Fixed:** OptiScaler edge version detection now prioritizes the most recent tag correctly
  - Improved version comparison logic for bleeding-edge builds

### UI Improvements
- **Fixed:** `winmm.dll` now appears correctly in `filenameComboBox` for OptiScaler DLL selection
- **Added:** Checkbox dependency logic - `gputempCheckBox` and `cputempCheckBox` now automatically enable their corresponding average load checkboxes when checked
  - Improves user experience by preventing invalid configurations

### Theme System
- **Added:** Complete dark/light theme system with `themeunit.pas`
  - Automatic desktop environment detection (GNOME/KDE/other)
  - Theme preference persistence in config file
  - Proper GTK color handling for GNOME compatibility
  - Smooth theme toggle functionality

## Fixes

### MangoHud
- **Removed:** `pci_dev` from MangoHud config output (deprecated option)

### OptiScaler Installation
- **Improved:** OptiScaler installation process now preserves existing fgmod files
  - Prevents accidental overwrite of user customizations

## Documentation

- **Added:** `CONTRIBUTING.md` with comprehensive development guidelines
  - Code style standards
  - Testing procedures
  - Pull request workflow
- **Added:** GitHub issue templates for better bug reporting and feature requests
- **Added:** Flathub repository installation instructions in README

## Repository Maintenance

- **Added:** `*.tar.gz` to `.gitignore` to prevent accidental commits of archive files
- **Improved:** Build workflow simplifications and versioning improvements
  - Exported `VERSION` variable for better build automation
  - Removed obsolete workarounds

## Metainfo Updates

- **Updated:** Desktop file and metainfo for 1.7.0 release compatibility
- **Updated:** geSpeedButton hint text for Tweaks tab clarity

---

## Breaking Changes

None

## Known Issues

None

## Contributors

Thanks to all contributors who helped with this release!

---

**Full Changelog:** [v1.7.0...v1.7.1](https://github.com/benjamimgois/goverlay/compare/v1.7.0...v1.7.1)
