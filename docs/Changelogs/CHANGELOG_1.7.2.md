# GOverlay 1.7.2 Changelog

**Release Date:** January 15, 2026

## New Features

### Save As Functionality
- **Added:** "Save As" feature for configuration files
  - Users can now save MangoHud.conf to custom directories
  - Users can now save vkBasalt.conf to custom directories
  - Folder selection dialog for easy file management
  - Accessible from MangoHud and vkBasalt tabs

### OptiScaler Auto-Installation
- **Added:** Automatic OptiScaler installation for FGMOD
  - Automatically checks for OptiScaler dependencies on startup
  - Downloads and installs stable version if not found
  - Desktop notification system for installation status
  - Seamless integration with FGMOD initialization

### XDG Base Directory Specification Compliance

- **Implemented:** Complete XDG Base Directory specification compliance across all configuration paths
  - Ensures proper separation of user data and configuration files
  - Improves compatibility with Flatpak and sandboxed environments
  - Follows freedesktop.org standards for better Linux integration

#### MangoHud Configuration
- **Fixed:** MangoHud config paths now correctly use XDG-compliant directories
  - Native mode: Uses `$XDG_CONFIG_HOME/MangoHud/` (fallback: `~/.config/MangoHud/`)
  - Flatpak mode: Uses `$HOST_XDG_CONFIG_HOME` or `/var/home/$USER/.config/MangoHud/`
  - Ensures configuration files are stored in proper user config directories
- **Fixed:** MangoHud log paths now use XDG-compliant directories
  - Native logs: `$XDG_DATA_HOME/goverlay/`
  - Flatpak logs: `$HOST_XDG_DATA_HOME/goverlay/`
  - New function `GetGOverlayDataDir()` for consistent path handling

#### Log File Management
- **Fixed:** nohup.out log file now saved to XDG-compliant directory
  - Native: `$XDG_DATA_HOME/goverlay/logs/`
  - Flatpak: `$HOST_XDG_DATA_HOME/goverlay/logs/`
  - Automatic log directory creation
  - No more log files in current working directory

#### FGMOD Integration
- **Migrated:** FGMOD to XDG Base Directory specification
  - FGMOD scripts now stored in `$XDG_DATA_HOME/goverlay/fgmod/` (fallback: `~/.local/share/goverlay/fgmod/`)
  - Native mode: Uses standard XDG data directory
  - Flatpak mode: Uses `$HOST_XDG_DATA_HOME` or `/var/home/$USER/.local/share/goverlay/fgmod/`
  
- **Added:** Automatic FGMOD migration from old to XDG-compliant paths
  - Detects existing FGMOD installations in legacy locations
  - Automatically migrates to new XDG-compliant paths on application startup
  - Migration sources include:
    - Old Flatpak sandbox path: `/var/home/$USER/fgmod/`
    - Legacy home directory: `~/fgmod/`
  - Preserves user customizations during migration
  - Creates necessary directory structure automatically
  - Disabled automatic overwrite of newer FGMOD versions

#### All Configuration Paths
- **Extended:** XDG compliance to all application configuration paths
  - vkBasalt configuration paths
  - OptiScaler configuration paths
  - GOverlay's own configuration files
  - Consistent use of `HOST_XDG_CONFIG_HOME` and `HOST_XDG_DATA_HOME` environment variables

## Fixes

### FGMOD Script Execution
- **Fixed:** Critical FGMOD script execution error
  - Resolved "`--: command not found`" error when launching Steam games
  - Updated script to correctly parse and filter the `--` argument separator
  - Script now properly handles gamemoderun integration
  - Updated embedded FGMOD script in `fgmod_resources.pas`
  - Updated FGMOD version banner to v1.7.2
  - Changed `exec "$@"` to `"$@"` to fix Steam process tracking

### User Interface
- **Fixed:** Menu item visibility across tabs
  - Save and Save As options now properly visible in vkBasalt tab
  - OptiScaler and Tweaks tabs now show only relevant menu items (Donate and About)
  - MangoHud-specific items (Save Custom, Deck Presets) hidden from vkBasalt tab
  - Run vkcube and Run PasCube items hidden from OptiScaler and Tweaks tabs
  - Improved menu clarity and reduced clutter in each tab

- **Fixed:** Visibility logic for "Auto Enable" (fgmod) controls
  - Fixed issue where `geSpeedButton` and `geLabel` were hidden on all tabs when Global Enable was active
  - Controls are now correctly hidden only on MangoHud tabs (to prevent double loading)
  - Controls remain visible and functional on vkBasalt, OptiScaler, and Tweaks tabs
  - Displays clear "MangoHud will be displayed in every vulkan application" message instead of launch command when active in MangoHud tab


- **Refactored:** UI component migration from TCheckGroup to TGroupBox
  - Migrated `generalCheckGroup` to `generalGroupBox` with individual checkboxes:
    - `simdeckCheckBox`, `gamemodeCheckBox`, `enhdrCheckBox`
    - `enwaylandCheckBox`, `actprotonlogsCheckBox`, `usesdlCheckBox`
  - Migrated `graphicsCheckGroup` to `graphicsGroupBox`
  - Improved UI flexibility and maintainability
  - Better control over individual checkbox states

- **Added:** Gamemode checkbox auto-disable
  - Automatically disables `gamemodeCheckbox` when `gamemoderun` is not found
  - Prevents user confusion with unavailable features
  - Complements existing "gamemode is missing" warning message


### Flatpak Compatibility
- **Improved:** Better handling of Flatpak environment variables
  - Proper detection and usage of host system paths
  - Fallback mechanisms for missing environment variables
  - Enhanced compatibility with different Flatpak runtime versions

## Metainfo Updates

- **Added:** `vcs-browser` URL to metainfo to resolve Flathub linter warning
  - Improves Flathub listing quality
  - Provides direct link to source code repository
  - Complies with Flathub best practices

---

## Breaking Changes

### Path Migration Required

Users upgrading from previous versions will experience automatic migration of FGMOD files:
- **From:** `~/fgmod/` or `/var/home/$USER/fgmod/` (Flatpak sandbox)
- **To:** `~/.local/share/goverlay/fgmod/` or `$HOST_XDG_DATA_HOME/goverlay/fgmod/` (Flatpak)

This migration is automatic and preserves all user customizations. No manual action required.

## Known Issues

None

## Contributors

Thanks to all contributors who helped with this release!

---

**Full Changelog:** [v1.7.1...v1.7.2](https://github.com/benjamimgois/goverlay/compare/v1.7.1...v1.7.2)
