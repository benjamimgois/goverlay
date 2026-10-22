# Proposal: Fix DLSS-NR RDNA4 Detection, Download, and Runtime Deployment

## Why
Users with AMD RDNA 4 graphics cards (such as Radeon RX 9060 XT / Navi 44, PCI ID `1002:7590`) are currently unable to run DLSS-NR with the intended RDNA 4 runtime. Instead, games either suffer from crippling performance degradation (~19 ms neural evaluation time due to RDNA 3 FP16 twin emulation), enter infinite feature re-creation loops, or fail to initialize altogether.

This occurs because:
1. `DetectRDNAArchitecture` only inspects textual name substrings and misses RDNA 4 PCI device IDs (`7590`, `7591`, `7500`, `7501`, etc.) found in sysfs (`/sys/class/drm/card*/device/device` and `uevent`).
2. GOverlay's model extraction flow hardcodes downloading the RDNA 3 runtime package first (`DLSSNR-RDNA3`) and never downloads the RDNA 4 package (`DLSSNR-AMD`), leaving `~/.local/share/goverlay/dlss-nr-rdna4/` absent.
3. `bgmod` lacks GPU architecture detection and maps `DLSSNR_ARCH=0` (Auto-detect) directly to the `dlss-nr-rdna3` channel, with a silent fallback that always picks RDNA 3 whenever `dlss-nr-rdna4` is missing.

## What Changes
- **RDNA 4 Hardware Detection**: Extend `DetectRDNAArchitecture` in `systemdetector.pas` with complete RDNA 4 PCI device IDs (Navi 44: `7590`, `7591`, `7592`, `7593`; Navi 48: `7500`, `7501`, `7502`, `7503`, `7504`, `7505`, `7506`) and model strings (`rx 9060`, `rx 9070`, `navi 44`, `navi 48`, `navi44`, `navi48`).
- **Target Architecture Package Download**: Update `ExtractDlssNrModel` and DLSS-NR installation logic in `optiscaler_update.pas` to download the specific target architecture package based on detected hardware or user override (downloading `rdna4` from `mochizuki0323/DLSSNR-AMD` when RDNA 4 is active, or `rdna3` from `mauri870/DLSSNR-RDNA3` when RDNA 3 is active), and provide support for installing/updating the active architecture runtime.
- **Resolved Architecture in Configuration and `bgmod`**:
  - In `overlay_config.pas` and `optiscaler_tab.pas`, save the resolved effective architecture alongside or within `bgmod.conf` so `bgmod` knows the exact architecture even when set to Auto-detect.
  - In `bgmod.lpr`, add lightweight PCI ID/sysfs architecture resolution when `DLSSNR_ARCH=0` (Auto) or respect the resolved architecture key, preventing unconditional fallback to `dlss-nr-rdna3` on RDNA 4 systems.
  - Ensure `bgmod` logs the chosen architecture and warns if a fallback occurs.

## Capabilities

### New Capabilities
None.

### Modified Capabilities
- `dlss-nr-runtime-management`: Support RDNA 4 PCI ID device detection, architecture-aware runtime package downloads for both RDNA 4 and RDNA 3, and accurate architecture channel resolution in both GOverlay UI and `bgmod`.

## Impact
- **Code**: `systemdetector.pas`, `optiscaler_update.pas`, `optiscaler_tab.pas`, `overlay_config.pas`, `bgmod.lpr`, and automated test suites (`tests/logic/logic_test_cases.pas`, `tests/gui/gui_test_cases.pas`).
- **Storage**: `~/.local/share/goverlay/dlss-nr-rdna4/` will now be properly populated for RDNA 4 users.
- **Compatibility**: Backwards compatible with existing RDNA 3 users and existing `bgmod.conf` files.
