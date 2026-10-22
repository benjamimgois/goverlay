## Context

See proposal.md and spec.md for background and requirements.

Previously, `fsrversionLabel` and `fsrversionComboBox` existed in `overlayunit.lfm` inside `optiscalerGroupBox`, but `fsrversionComboBoxChange` forced `Visible := False` and locked `ItemIndex := 0`. The modernized OptiScaler tab layout in `optiscaler_tab.pas` organizes settings into styled sub-cards, where sub-card 2 (`FOsSpatialSec`, titled "Upscaler") currently displays:
- "Prefered upscaler" (`preferredUpscalerLabel` and `preferredUpscalerComboBox`)
- "Spoof DLSS" toggle (`FSpoofToggle`)
- "Force FSR4-i8" toggle (`FForceFsr4Toggle`)

In addition, previous code created legacy `FSR4_LATEST` and `FSR4_INT8` directories directly within `optiscaler-stable/` and `optiscaler-edge/`, copying them recursively to game configuration directories. These legacy folders are deprecated and replaced by the single centralized `~/.local/share/goverlay/FSR4/` tree.

## Goals / Non-Goals

**Goals:**
- Reparent and style `fsrversionLabel` and `fsrversionComboBox` into `FOsSpatialSec`, positioning them directly below `preferredUpscalerComboBox`.
- Populate `fsrversionComboBox` with `"Latest"` (default), `"4.1.1b"`, and `"4.0.2c"`, keeping the combobox permanently visible.
- Establish a centralized `~/.local/share/goverlay/FSR4/` directory with subfolders:
  - `Latest/`: native `amd_fidelityfx_upscaler_dx12.dll` from the OptiScaler release.
  - `4.1.1b/`: downloaded from `OptiScaler-builds/releases/download/fsr-int8-411b/`.
  - `4.0.2c/`: downloaded from `OptiScaler-builds/releases/download/fsr-int8/`.
- Deprecate and remove creation and syncing of legacy `FSR4_LATEST` and `FSR4_INT8` folders in `optiscaler-stable`, `optiscaler-edge`, and game profiles.
- Ensure `FSR4/Latest/` acts as an immutable restore point, refreshed only when new OptiScaler packages are extracted.
- Ensure combobox selections copy the chosen DLL only to the target game profile (`gameconfig/<game>/` or `gameconfig/global/`).
- Persist version in `goverlay.vars` and sync with `Settings.FsrversionItemIndex`.

**Non-Goals:**
- Changing `Fsr4ForceEnableInt8` behavior (retained as independent toggle switch).
- Downloading non-DirectX12 upscalers.

## Decisions

### Decision 1: Centralized `FSR4/` directory and Legacy Folder Deprecation

- **Implementation**: Helper function `GetFSR4BasePath: string` returning `IncludeTrailingPathDelimiter(GetGOverlayDataPath) + 'FSR4'`.
- **Structure**:
  - `GetFSR4BasePath + '/Latest/'`
  - `GetFSR4BasePath + '/4.1.1b/'`
  - `GetFSR4BasePath + '/4.0.2c/'`
- **Removal of Legacy Directories**:
  - Remove `ForceDirectories(... + 'FSR4_LATEST')` and `ForceDirectories(... + 'FSR4_INT8')` from `optiscaler_update.pas`.
  - Remove shell copy scripts syncing `FSR4_LATEST` and `FSR4_INT8` into target profiles from `optiscaler_update.pas`, `bgmod_resources.pas`, and `sidebar_nav.pas`.
  - If existing `FSR4_LATEST` and `FSR4_INT8` directories exist in `optiscaler-stable` or `optiscaler-edge`, clean them up so the cache directories remain uncluttered.

### Decision 2: Immutability and Restoration of "Latest"

- During `TOptiscalerTab.InstallOptiScaler` and `TOptiscalerTab.UpdateButtonClick`:
  1. Extract OptiScaler release to `TargetCacheDir`.
  2. Copy native `TargetCacheDir/amd_fidelityfx_upscaler_dx12.dll` to `GetFSR4BasePath + '/Latest/amd_fidelityfx_upscaler_dx12.dll'`.
  3. Download `4.1.1b` and `4.0.2c` DLLs using `RunCurlWithProgress` / `DownloadFile` into their respective subfolders under `GetFSR4BasePath`.
- When applying configuration in `overlay_config.pas`:
  - `Settings.FsrversionItemIndex = 0`: copy from `FSR4/Latest/amd_fidelityfx_upscaler_dx12.dll` to `FGModDestPath`.
  - `Settings.FsrversionItemIndex = 1`: copy from `FSR4/4.1.1b/amd_fidelityfx_upscaler_dx12.dll` to `FGModDestPath`.
  - `Settings.FsrversionItemIndex = 2`: copy from `FSR4/4.0.2c/amd_fidelityfx_upscaler_dx12.dll` to `FGModDestPath`.
- Auto-heal: If `FSR4/Latest/amd_fidelityfx_upscaler_dx12.dll` does not exist on disk but `TargetCacheDir/amd_fidelityfx_upscaler_dx12.dll` exists, copy it to `FSR4/Latest/` immediately.

### Decision 3: Sub-card 2 ("Upscaler") Layout Reflow

- In `optiscaler_tab.pas`:
  - Reparent `fsrversionLabel` and `fsrversionComboBox` to `FOsSpatialSec`.
  - Apply `DarkLbl` and `DarkCombo` styling.
  - Position within `FOsSpatialSec`:
    - `preferredUpscalerLabel.SetBounds(10, Y0, ColW - 20, 16);`
    - `preferredUpscalerComboBox.SetBounds(10, Y0 + 18, ComboW, 26);`
    - `fsrversionLabel.SetBounds(10, Y0 + 52, ColW - 20, 16);`
    - `fsrversionComboBox.SetBounds(10, Y0 + 70, ComboW, 26);`
    - `FSpoofToggle.SetBounds(10, Y0 + 106, ColW - 20, 20);`
    - `FForceFsr4Toggle.SetBounds(10, Y0 + 138, ColW - 20, 20);`
  - Increase `FOsSpatialSec` vertical height by 52px to prevent clipping.

### Decision 4: Serialization and Loading

- `goverlay.vars` format:
  - `fsrversion=Latest` (index 0)
  - `fsrversion=4.1.1b` (index 1)
  - `fsrversion=4.0.2c` (index 2)
- Backward compatibility: load recognizes legacy `4.0.2c INT8` or `4.0.2c (INT8)` and maps it to index 2.

## Risks / Trade-offs

- [Risk] Alternative DLL downloads fail due to network outage or rate limiting.
  - Mitigation: Downloads are performed non-fatally with warnings. If a selected alternative DLL is absent when saving, GOverlay logs a warning and falls back to `Latest` to ensure game launchability.
- [Risk] Upstream OptiScaler package structure changes in future versions.
  - Mitigation: Extraction verifies existence of `amd_fidelityfx_upscaler_dx12.dll` before attempting copy, logging a clear diagnostic if missing.
