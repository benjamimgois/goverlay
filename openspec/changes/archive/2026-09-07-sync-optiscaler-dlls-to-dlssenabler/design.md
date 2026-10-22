## Context

`CheckAndInstallDlssEnabler` in `optiscaler_update.pas` manages the download and setup of `dlssenabler-stable` and `dlssenabler-edge`. Currently, it only extracts the DLSS Enabler core ZIP and downloads the Streamline SDK.

At runtime, `CopyOptiScalerGameFiles` (`sidebar_nav.pas`) deploys files from `GetDlssEnablerPath(IsStable)` to the game's profile directory (`~/.local/share/goverlay/gameconfig/<game>/`). The launch wrapper `bgmod` also uses `dlssenabler-stable`/`dlssenabler-edge` as `SourceDir` to install libraries into the game directory.

Because the DLSS Enabler cache directories were missing FSR, XeSS, FakeNVAPI, and `dlssg_to_fsr3_amd_is_better.dll`, games running with DLSS Enabler failed checks, lacked frame generation bridges, and suffered from missing DLL warnings and runtime crashes.

## Goals / Non-Goals

**Goals:**
- Provide a robust synchronization helper `SyncOptiScalerFilesToDlssEnabler(AIsStable: Boolean)` in `optiscaler_update.pas`.
- Ensure all OptiScaler supporting DLLs (`amd_fidelityfx_*.dll`, `libxess*.dll`, `libxell.dll`, `dlssg_to_fsr3_amd_is_better.dll`, `fakenvapi.*`), directories (`D3D12_Optiscaler/`, `plugins/`, `Licenses/`), scripts, and configuration are present in `dlssenabler-stable` and `dlssenabler-edge`.
- Protect native DLSS Enabler binaries from being overwritten (`version.dll`, `sl.*.dll`, `WinPixEventRuntime.dll`, `NvLowLatencyVk.dll`, `nvngx_deepdvc.dll`, and `goverlay.vars`).
- Add self-healing verification so existing installations missing these files are updated on launch without re-downloading DLSS Enabler.

**Non-Goals:**
- Modifying how OptiScaler standalone operates.
- Altering the upstream DLSS Enabler ZIP archives or GitHub release structures.

## Decisions

1. **Centralized Helper in `optiscaler_update.pas` (`SyncOptiScalerFilesToDlssEnabler`):**
   - Resolves source OptiScaler path via `GetBGModOriginalPath` (stable) or `GetBGModOriginalEdgePath` (edge).
   - Resolves target DLSS Enabler path via `GetDlssEnablerPath(AIsStable)`.
   - If the source OptiScaler directory is missing, invokes `CheckAndInstallOptiScaler` to ensure source files are ready.
   - Iterates through a defined list of supporting files and copies them into the target directory if they are missing or if force-sync is enabled.
   - Recursively copies required directories (`D3D12_Optiscaler`, `plugins`, `Licenses`).
   - Specifically protects DLSS Enabler native files: `version.dll`, `sl.*.dll`, `WinPixEventRuntime.dll`, `NvLowLatencyVk.dll`, `nvngx_deepdvc.dll`, and `goverlay.vars`.

2. **Integration into `CheckAndInstallDlssEnabler`:**
   - Fresh install/update: After extracting DLSS Enabler ZIP and installing Streamline SDK, invoke `SyncOptiScalerFilesToDlssEnabler(AIsStable)`.
   - Existing cache check (early exit): If `version.dll` and `goverlay.vars` already exist, check if critical supporting files (such as `dlssg_to_fsr3_amd_is_better.dll` and `amd_fidelityfx_upscaler_dx12.dll`) are present. If any are missing, perform `SyncOptiScalerFilesToDlssEnabler(AIsStable)` to self-heal the cache.

3. **Alternative Considered:**
   - *Relying on `bgmod.lpr` to copy missing files on the fly during game launch:* Rejected. `CopyOptiScalerGameFiles` in GOverlay seeds the game profile folder from the cache directory ahead of time. If the cache is incomplete, the game profile folder and backups become incomplete, causing inconsistencies and launch errors.

## Risks / Trade-offs

- **[Risk]** OptiScaler cache not yet initialized when DLSS Enabler is installed.
  - **Mitigation:** `SyncOptiScalerFilesToDlssEnabler` checks for `OptiScaler.dll` in the OptiScaler cache, and invokes `CheckAndInstallOptiScaler` if needed before syncing.
- **[Risk]** Overwriting DLSS Enabler's own `version.dll` or Streamline components.
  - **Mitigation:** The sync function explicitly skips any file starting with `sl.` or named `version.dll`, `WinPixEventRuntime.dll`, `NvLowLatencyVk.dll`, `nvngx_deepdvc.dll`, or `goverlay.vars`.
