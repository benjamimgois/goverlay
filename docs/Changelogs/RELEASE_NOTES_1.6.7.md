# Goverlay 1.6.7

## What's New

Version 1.6.7 brings significant improvements to OptiScaler management, enhanced Flatpak Steam support, and better configuration persistence.

### 🎯 Highlights

**OptiScaler Architecture Overhaul**
- Unified installation directory (`~/fgmod` for all channels)
- 40% reduction in code complexity
- Faster, more reliable installations
- Comprehensive debug logging (50+ checkpoints)

**Flatpak Steam Integration**
- MangoHud configuration now automatically syncs to Flatpak Steam
- No manual file copying required

**Smart Channel Detection**
- Automatic detection of installed OptiScaler version
- ComboBox auto-selects correct channel on startup

**GNOME Desktop Fixes**
- Fixed tab text visibility with dark themes
- Enhanced theme color handling

### ✨ New Features

- Automatic MangoHud configuration for Flatpak Steam (`~/.var/app/com.valvesoftware.Steam/config/MangoHud/`)
- Smart OptiScaler channel detection (stable vs bleeding-edge)
- Unified OptiScaler directory structure
- Dual-location configuration saves for Flatpak compatibility

### 🐛 Bug Fixes

- Fixed OptiScaler launch command using wrong path for bleeding-edge channel
- Fixed FSR "Latest (FP8)" version not being saved to goverlay.vars
- Fixed channel selection not matching installed version on startup
- Fixed update notification label persisting after installation
- Fixed tab text visibility on GNOME desktop environment

### ⚡ Improvements

- Enhanced debug logging throughout OptiScaler operations
- Better error handling with actionable troubleshooting guidance
- Improved configuration file parsing and persistence
- Cleaner UI state management after installations

## Upgrade Notes

### For OptiScaler Users

**Bleeding-Edge Channel:**
- Previous location: `~/fgmod-edge/`
- New location: `~/fgmod/`
- On first update, a clean installation will be performed in `~/fgmod/`
- You can safely delete the old `~/fgmod-edge/` directory after updating

**Stable Channel:**
- No action required - everything continues to work as before

### For Flatpak Steam Users

MangoHud settings now automatically apply to both native and Flatpak Steam installations - no manual configuration needed!

## Installation

**From Source:**
```bash
make
sudo make install
```

**Flatpak:** Available on Flathub

**Dependencies:** curl, 7z, git, qt6pas

---

**Full Changelog:** [1.6.6...1.6.7](https://github.com/benjamimgois/goverlay/compare/1.6.6...1.6.7)

**Report Issues:** https://github.com/benjamimgois/goverlay/issues

**Support the Project:** https://ko-fi.com/benjamimgois
