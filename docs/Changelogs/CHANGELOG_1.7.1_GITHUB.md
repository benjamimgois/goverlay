## 🚀 What's New in v1.7.1

### ✨ New Features

#### MangoHud
- Added **`fex_stats`** checkbox option for FEX-Emu statistics display
- Improved **time display** configuration to properly add `time` and `time_no_label` options (replaces legacy `time#`)
- Fixed **FPS-only preset button** to correctly clear config and write only `fps_only` line with save notification

#### OptiScaler
- Added **GPU vendor spoofing** (`spoofCheckBox`) to modify `Dxgi=` parameter in OptiScaler.ini
- Fixed **edge version detection** to correctly prioritize the most recent bleeding-edge tag

#### UI Improvements
- Added **checkbox dependencies**: GPU/CPU temperature checkboxes now automatically enable their corresponding average load checkboxes
- Fixed `winmm.dll` appearing correctly in filename dropdown for OptiScaler DLL selection

#### Theme System
- Implemented complete **dark/light theme system** with persistence
- Automatic desktop environment detection (GNOME/KDE/other)
- Proper GTK color handling for GNOME compatibility

### 🐛 Bug Fixes
- Removed deprecated `pci_dev` option from MangoHud config output
- Improved OptiScaler installation to preserve existing fgmod files

### 📚 Documentation
- Added `CONTRIBUTING.md` with development guidelines
- Added GitHub issue templates for better bug reporting
- Added Flathub repository installation instructions

### 🛠️ Repository Maintenance
- Improved build workflow and versioning automation
- Added `*.tar.gz` to `.gitignore`

---

**Full Changelog**: https://github.com/benjamimgois/goverlay/compare/v1.7.0...v1.7.1
