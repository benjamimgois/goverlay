# Changelog - Version 1.6.5

## Bug Fixes

### Configuration Persistence
- **Fixed network interface selection not persisting on reload** ([#6c1c198d](https://github.com/benjamimgois/goverlay/commit/6c1c198d))
  - Network interface selected in MangoHud configuration now correctly appears selected when reopening the application
  - Issue was caused by ItemIndex not being reset before searching for saved values

- **Fixed font file path saving in MangoHud configuration** ([#48ee806b](https://github.com/benjamimgois/goverlay/commit/48ee806b))
  - Font selection now correctly creates `font_file=` line in MangoHud.conf
  - Selected fonts are now properly restored when reopening the application
  - Fixed duplicate `.ttf` extension issue in font file paths

### User Experience Improvements
- **Keep UI responsive during large file downloads** ([#de86c419](https://github.com/benjamimgois/goverlay/commit/de86c419))
  - Application no longer appears frozen during OptiScaler and large file downloads
  - Implemented responsive download loop with `Application.ProcessMessages`
  - Particularly beneficial for users with slow internet connections

- **Make SendNotification asynchronous for instant response** ([#f149cfe1](https://github.com/benjamimgois/goverlay/commit/f149cfe1))
  - Clipboard copy button now responds instantly
  - Notifications are sent asynchronously without blocking UI thread
  - Fixes slow response time on native installations

### Path and Configuration Fixes
- **Use absolute path for fgmod launch command** ([#294fae9d](https://github.com/benjamimgois/goverlay/commit/294fae9d))
  - OptiScaler launch command now uses absolute path format: `/home/user/fgmod/fgmod %command%`
  - Improves compatibility with non-Steam game launchers
  - Previously used relative path `~/fgmod/fgmod %command%` which caused issues

- **Use ~/.config/vkBasalt/ for both Flatpak and native installations** ([#bc829e5d](https://github.com/benjamimgois/goverlay/commit/bc829e5d))
  - ReShade shader paths are now consistently saved to `~/.config/vkBasalt/` regardless of installation method
  - Eliminates Flatpak-specific path inconsistencies
  - Ensures configuration portability between Flatpak and native installations

### Code Quality
- **Fix typos: replace 'avaiable' with 'available'** ([#3b4b6d89](https://github.com/benjamimgois/goverlay/commit/3b4b6d89))
  - Corrected spelling throughout codebase and user-facing messages

## Flatpak Improvements
- **Needed changes for latest Flatpak** ([#9ac62524](https://github.com/benjamimgois/goverlay/commit/9ac62524))
  - Updated Flatpak manifest for compatibility with latest runtime
  - Merged Flatpak improvements from community contributions

- **Add metainfo** ([#55eb4189](https://github.com/benjamimgois/goverlay/commit/55eb4189))
  - Added AppStream metainfo file for better software center integration

## Documentation
- **Update README.md** ([#d4a63d27](https://github.com/benjamimgois/goverlay/commit/d4a63d27), [#efe8351f](https://github.com/benjamimgois/goverlay/commit/efe8351f))
  - Updated documentation with latest features and installation instructions

## Community Contributions
- Thanks to [@Twig6943](https://github.com/Twig6943) for Flatpak improvements and metainfo additions
  - PR #228: Latest Flatpak changes
  - PR #227: Metainfo addition
  - PR #225: Sync and asset management

---

## Technical Details

### Files Changed
- `overlayunit.pas`: Configuration loading/saving fixes, async notifications, UI responsiveness
- `optiscaler_update.pas`: Download responsiveness improvements
- `data/goverlay.sh.flatpak`: Path consistency fixes
- `io.github.benjamimgois.goverlay.metainfo.xml`: New AppStream metadata
- Various manifest files: Flatpak runtime updates

### Breaking Changes
None - this is a bug fix and improvement release.

### Upgrade Notes
Users upgrading from 1.6.4 will benefit from:
1. Improved configuration persistence (network interface and font selections)
2. More responsive UI during downloads and notifications
3. Better compatibility with non-Steam launchers (absolute paths)
4. Consistent vkBasalt paths across installation methods

---

**Release Date:** TBD
**Previous Version:** 1.6.4 (commit: 3374c45f)
**Contributors:** @benjamimgois, @Twig6943
