## 🚀 What's New in v1.7.2

### ✨ New Features

#### 💾 Save As Functionality
- **Save your configs anywhere!** New "Save As" feature for MangoHud and vkBasalt configurations
  - Easy folder selection dialog
  - Export configs to any directory you choose

#### 🤖 OptiScaler Auto-Installation
- **Zero hassle setup!** OptiScaler now installs automatically for FGMOD
  - Automatic dependency checking on startup
  - Downloads stable version if not found
  - Desktop notifications keep you informed

#### 📁 Complete XDG Compliance

This release brings **full XDG Base Directory specification compliance**, ensuring GOverlay follows Linux standards for configuration and data storage.

##### MangoHud & Logs
- **Config paths** now correctly use XDG directories:
  - Native: `$XDG_CONFIG_HOME/MangoHud/`
  - Flatpak: `$HOST_XDG_CONFIG_HOME` with proper fallbacks
- **Log files** moved to proper locations:
  - Native: `$XDG_DATA_HOME/goverlay/`
  - Flatpak: `$HOST_XDG_DATA_HOME/goverlay/`
- **No more nohup.out clutter** in your working directories!

##### FGMOD Integration
- **New location:** `$XDG_DATA_HOME/goverlay/fgmod/` (defaults to `~/.local/share/goverlay/fgmod/`)
- **Automatic migration** from legacy paths (`~/fgmod/` or Flatpak sandbox)
  - Preserves all customizations
  - Creates directories as needed
  - Prevents accidental overwrites of newer versions

##### All Configs XDG-Ready
- **Extended compliance** to all configuration paths:
  - vkBasalt
  - OptiScaler
  - GOverlay settings
  - Consistent environment variable usage

### 🐛 Bug Fixes

#### FGMOD Script Execution
- **Fixed critical Steam launch error:** "`--: command not found`"
  - Properly handles argument separator
  - Fixed process tracking for Steam integration
  - Updated to version 1.7.2

#### User Interface
- **Menu cleanup:** Context menus now show only relevant items per tab
  - Save/Save As visible in vkBasalt tab
  - Cleaner OptiScaler and Tweaks tab menus

- **Fixed:** "Auto Enable" visibility logic
  - Controls now remain visible on non-MangoHud tabs even when Global Enable is active

  
- **UI refactor:** Migrated from TCheckGroup to TGroupBox
  - Better control and flexibility
  - Individual checkbox management

- **Gamemode protection:** Checkbox auto-disables when `gamemoderun` not found
  - Prevents confusion with unavailable features

#### Flatpak Compatibility
- Enhanced environment variable handling
- Better fallback mechanisms
- Improved compatibility across runtime versions

### 📦 Metainfo
- Added `vcs-browser` URL for improved Flathub listing quality

---

### ⚠️ Migration Notes

**Automatic & Seamless:** FGMOD files will be automatically migrated from legacy locations to the new XDG-compliant path on first launch. All customizations are preserved—no manual action required!

---

**Full Changelog**: https://github.com/benjamimgois/goverlay/compare/v1.7.1...v1.7.2
