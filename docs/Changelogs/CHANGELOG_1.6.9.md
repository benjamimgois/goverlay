# Changelog - Version 1.6.9

## What's New Since 1.6.8

Version 1.6.9 delivers substantial improvements to Flatpak compatibility, enhanced testing tools integration, and a new GPU selection option for multi-GPU users. This release focuses on fixing Flatpak runtime detection and improving the `pascube`/`vkcube` fallback mechanism.

### 🎯 Major Highlights

**1. Flatpak Runtime Detection Fix**
   - Fixed incorrect detection of MangoHud and vkBasalt Flatpak runtimes
   - Corrected the search pattern for `flatpak list --columns=ref` output
   - No more false "Missing runtime" warnings when runtimes are installed

**2. PasCube/vkCube Testing Integration**
   - Prioritized `pascube` over `vkcube` for MangoHud/vkBasalt effect testing
   - Automatic fallback to `vkcube` when `pascube` is not available
   - Proper Wayland support with `vkcube-wayland` in Flatpak mode

**3. Multi-GPU Configuration**
   - Added "Use both GPUs" option for simpler multi-GPU setups
   - Improved `gpu_list` configuration handling

---

## Flatpak Improvements

### Runtime Detection
- **Fixed MangoHud/vkBasalt runtime detection**
  - Previous versions incorrectly searched for `runtime/org.freedesktop.Platform.VulkanLayer...`
  - Corrected to search for `org.freedesktop.Platform.VulkanLayer...` (without `runtime/` prefix)
  - Properly detects installed MangoHud 25.08 and vkBasalt 25.08 runtimes

### Fgmod Path Handling
- **Fixed fgmod path for Flatpak persist directory**
  - `commandLabel` now displays the correct `~/.var/app/io.github.benjamimgois.goverlay/fgmod` path
  - `FixFgmodPathInScript` sets the correct fgmod path when in Flatpak mode

### Permissions
- Added `--talk-name=org.freedesktop.Flatpak` permission for runtime detection via `flatpak-spawn`

---

## Testing Tools

### PasCube Priority
- **PasCube is now the preferred testing tool**
  - Application automatically uses `pascube` when available
  - Falls back to `vkcube` if `pascube` is not installed
  - User notification when falling back to vkcube

### Wayland Support
- **Improved Wayland support for vkcube**
  - In Flatpak + Wayland: uses `vkcube-wayland` binary
  - In Native + Wayland: uses `vkcube --wsi wayland` flag
  - Ensures correct WSI (Window System Integration) on all configurations

---

## New Features

### GPU Selection
- **Added "Use both GPUs" option**
  - New option in GPU configuration for multi-GPU systems
  - Simplified selection for hybrid graphics setups
  - Improved `gpu_list` configuration handling

---

## Bug Fixes Summary

| Issue | Fix |
|-------|-----|
| MangoHud/vkBasalt runtimes shown as missing | Fixed search pattern in `CheckDependencies()` |
| vkcube not working on Wayland in Flatpak | Use `vkcube-wayland` binary |
| fgmod path incorrect in Flatpak | Use persist directory path |
| Spelling errors in UI | Fixed typos in source code |

---

## Technical Details

### Files Modified

**overlayunit.pas**
- Fixed `CheckDependencies()` to search for correct runtime patterns
- Improved PasCube/vkCube fallback logic with Wayland detection
- Enhanced vkBasalt label click handler for proper testing
- Added Flatpak-specific vkcube-wayland handling

**io.github.benjamimgois.goverlay.yml**
- Added `--talk-name=org.freedesktop.Flatpak` permission
- Updated manifest for runtime detection support

### Code Changes

**Runtime Detection Fix:**
```diff
-if Pos('runtime/org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/25.08', Output) = 0 then
+if Pos('org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/25.08', Output) = 0 then
   Missing.Add('MangoHud runtime 25.08');

-if Pos('runtime/org.freedesktop.Platform.VulkanLayer.vkBasalt/x86_64/25.08', Output) = 0 then  
+if Pos('org.freedesktop.Platform.VulkanLayer.vkBasalt/x86_64/25.08', Output) = 0 then
   Missing.Add('vkBasalt runtime 25.08');
```

---

## Complete Feature List (1.6.8 → 1.6.9)

### New Features
✨ Added "Use both GPUs" option for multi-GPU configurations  
✨ Prioritized PasCube for MangoHud/vkBasalt testing  
✨ Automatic fallback to vkcube with user notification  

### Bug Fixes
🐛 Fixed Flatpak runtime detection for MangoHud 25.08  
🐛 Fixed Flatpak runtime detection for vkBasalt 25.08  
🐛 Fixed fgmod path in Flatpak using sandbox path instead of real home  
🐛 Fixed vkcube Wayland support in Flatpak mode  
🐛 Fixed spelling errors in UI and source code  

### Improvements
⚡ Enhanced PasCube/vkCube fallback logic  
⚡ Better Wayland detection and handling  
⚡ Improved dependency check for Flatpak environments  
⚡ Optimized system detection routines  

---

## Commits Since 1.6.8

| Commit | Description |
|--------|-------------|
| `91cd0e03` | Fix Flatpak runtime detection for MangoHud and vkBasalt |
| `65214c2e` | fix(flatpak): Use correct fgmod path for Flatpak persist directory |
| `5196732f` | feat(flatpak): Check for MangoHud/vkBasalt runtimes instead of disk files |
| `8a1a985f` | fix: Use vkcube-wayland in Flatpak and improve PasCube/vkCube fallback logic |
| `bcc2092e` | Add check for missing Flatpak runtimes (MangoHud/vkBasalt) on startup |
| `8e15e6ef` | fix pascube/vkcube fallback logic |
| `c24243f7` | Fix pascube/vkcube fallback logic, remove shadowed IsCommandAvailable |
| `34dbe1d9` | Fix spelling errors in UI and source code |
| `b7d17347` | change vkbasalt flatpak path |
| `bb7db6b3` | prioritize pascube execution on startup |
| `4e258ed0` | fix(flatpak): use real home for optiscaler |
| `5d5115a5` | feat: Add 'Use both GPUs' option |

---

## Compatibility

**Tested on:**
- CachyOS (Arch-based)
- Flatpak runtime org.kde.Platform 6.10
- Native and Flatpak installations
- Wayland and X11 sessions

**Flatpak Runtimes:**
- org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/25.08
- org.freedesktop.Platform.VulkanLayer.vkBasalt/x86_64/25.08

---

**Release Date:** December 2024  
**Previous Version:** 1.6.8  
**Contributors:** @benjamimgois  

**Full Changelog:** [1.6.8...1.6.9](https://github.com/benjamimgois/goverlay/compare/1.6.8...1.6.9)
