# Design: DLSS-NR RDNA4 Detection, Download, and Runtime Deployment

## Context
See `proposal.md` for background and motivation.
Currently:
- `DetectRDNAArchitecture` in `systemdetector.pas` inspects renderer strings, `GetSysGPUModel`, and sysfs files (`vendor`, `device`, `uevent`). However, the RDNA4 markers only check substrings (`navi4`, `gfx12`, `rx 9`, `radeon 9`, `9070`, `9060`, `9080`). When sysfs exposes raw device IDs such as `0x7590` (Navi 44 / RX 9060 XT), detection fails and falls back to `rdnaUnsupported`.
- `ExtractDlssNrModel` in `optiscaler_update.pas` unconditionally checks and downloads `rdna3` first, never downloading `rdna4` unless the RDNA3 download fails.
- `bgmod.lpr` does not detect GPU architecture and treats `DLSSNR_ARCH=0` (Auto-detect) as `dlss-nr-rdna3`. If `dlss-nr-rdna4` is missing on disk, it also silently falls back to `dlss-nr-rdna3`.

## Goals / Non-Goals

**Goals:**
- Reliably detect RDNA 4 GPUs via both model strings and PCI device IDs (Navi 44 and Navi 48 families).
- Download the matching architecture runtime (`dlss-nr-rdna4` from `mochizuki0323/DLSSNR-AMD` or `dlss-nr-rdna3` from `mauri870/DLSSNR-RDNA3`) based on the active or selected architecture.
- Ensure `bgmod` deploys the appropriate architecture channel (`dlss-nr-rdna4` vs `dlss-nr-rdna3`) without defaulting to RDNA 3 when running on RDNA 4 hardware.
- Log clear architecture resolution and fallback warnings in `bgmod.log`.
- Add test coverage for RDNA 4 device ID detection, runtime path resolution, and `bgmod` architecture dispatching.

**Non-Goals:**
- Modifying compiled upstream C++ binaries (`dlssnr_core.dll` or `OptiScaler.dll`).
- Supporting pre-RDNA3 architectures for DLSS-NR (neither upstream project supports RDNA 1 or 2).

## Decisions

### 1. Extended PCI Device ID and Name Detection in `systemdetector.pas`
- In `DetectRDNAArchitecture`, add known RDNA 4 Navi 44 (`7590`, `7591`, `7592`, `7593`) and Navi 48 (`7500`, `7501`, `7502`, `7503`, `7504`, `7505`, `7506`) device IDs to the RDNA 4 marker list.
- Also include variants formatted as `0x7590` and `1002:7590`.
- Retain existing name-based markers (`navi4`, `gfx12`, `rx 9`, `radeon 9`, `9060`, `9070`, `9080`).
- *Alternative considered*: Invoking `lspci -nn` or `vulkaninfo`. *Reason rejected*: Sysfs scanning is already implemented, fast, and works seamlessly inside Flatpak sandboxes without additional permissions.

### 2. Architecture-Aware Download and Extraction in `optiscaler_update.pas`
- When extracting weights or installing DLSS-NR tools in `ExtractDlssNrModel`, resolve the target architecture first:
  ```pascal
  TargetArch := DetectRDNAArchitecture;
  if TargetArch = rdnaUnsupported then TargetArch := rdna3;
  TargetArchStr := RDNAArchitectureToString(TargetArch); // 'rdna4' or 'rdna3'
  ```
- Search for `extract_model.sh` in the target architecture folder first, then the alternate folder.
- If missing, download the target architecture runtime package first (`CheckAndInstallDlssNr(TargetArchStr)`), falling back to the other only if the target download fails.
- In `CheckAndInstallDlssNr`, ensure RDNA 4 downloads unpack into `GetBGModDlssNrPath('rdna4')` (`dlss-nr-rdna4`) and update `goverlay.vars` accordingly.

### 3. Architecture Resolution in Configuration and `bgmod`
- When GOverlay writes `bgmod.conf`, it can write `DLSSNR_RESOLVED_ARCH` (e.g. `1` for RDNA4, `2` for RDNA3) while preserving `DLSSNR_ARCH` (0: Auto, 1: RDNA4, 2: RDNA3).
- In `bgmod.lpr`:
  - Read `DLSSNR_RESOLVED_ARCH`. If present and valid, use it when `DLSSNR_ARCH=0`.
  - If `DLSSNR_RESOLVED_ARCH` is not set and `DLSSNR_ARCH=0`, perform a lightweight sysfs device check for AMD RDNA 4 device IDs (`7590`..`7593`, `7500`..`7506`) to resolve `DlssNrArch`.
  - If the resolved channel directory (`dlss-nr-rdna4`) does not exist, log a prominent warning before falling back:
    `Log('Warning: Target DLSS-NR channel ' + ChannelFolder + ' not found in ' + BaseDir + '; falling back to available channel.');`
  - Log the final selected channel: `Log('DLSS-NR selected runtime channel: ' + ChannelFolder);`.

## Risks / Trade-offs

- **[Risk: New RDNA 4 PCI IDs released by AMD in future revisions]** → **Mitigation**: Detect both specific device IDs (`7590`..`7593`, `7500`..`7506`) and textual markers (`navi4`, `gfx12`, `rx 9`). The manual dropdown override allows users to force `RDNA 4` if auto-detection fails.
- **[Risk: Network failure during auto-download]** → **Mitigation**: Clean error logging with UI toast feedback, leaving any existing cached files untouched.
