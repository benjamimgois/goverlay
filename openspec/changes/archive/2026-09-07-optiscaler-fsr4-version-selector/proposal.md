## Why

Different games and GPU architectures (such as RDNA2, RDNA3, and specific DirectX 12 game engines) require different builds of FSR4—notably INT8 builds such as 4.1.1b and 4.0.2c—to maximize compatibility, stability, and frame rate without visual artifacts. Currently, GOverlay hides the FSR version selector and defaults to whatever version is bundled in the OptiScaler release. In addition, the current codebase creates legacy `FSR4_LATEST` and `FSR4_INT8` folders directly inside the OptiScaler cache. Users need an accessible combobox under "Prefered upscaler" to choose between "Latest" and alternative FSR4 versions, with automated background downloading and reliable restoration of the official "Latest" DLL from a single clean central repository.

## What Changes

- **UI Addition**: Add a permanently visible "FSR Version" combobox with label directly below "Prefered upscaler" inside the "Upscaler" sub-card (`FOsSpatialSec`) on the OptiScaler tab.
- **Combobox Options**: Provide three version choices: `"Latest"` (default, index 0), `"4.1.1b"` (index 1), and `"4.0.2c"` (index 2).
- **Centralized Directory Hierarchy**: Create and manage a central `FSR4/` directory under GOverlay's data directory (`~/.local/share/goverlay/FSR4/`) containing subfolders:
  - `Latest/`: Holds the pristine `amd_fidelityfx_upscaler_dx12.dll` extracted from the active OptiScaler release.
  - `4.1.1b/`: Holds `amd_fidelityfx_upscaler_dx12.dll` downloaded from `https://github.com/benjamimgois/OptiScaler-builds/releases/download/fsr-int8-411b/amd_fidelityfx_upscaler_dx12.dll`.
  - `4.0.2c/`: Holds `amd_fidelityfx_upscaler_dx12.dll` downloaded from `https://github.com/benjamimgois/OptiScaler-builds/releases/download/fsr-int8/amd_fidelityfx_upscaler_dx12.dll`.
- **Legacy Folder Removal**: Stop creating or syncing legacy `FSR4_LATEST` and `FSR4_INT8` directories inside `optiscaler-stable`, `optiscaler-edge`, or game configuration folders.
- **Latest Integrity & Restoration**:
  - Immediately upon extracting any OptiScaler release (stable or edge), the bundled `amd_fidelityfx_upscaler_dx12.dll` is backed up to `FSR4/Latest/amd_fidelityfx_upscaler_dx12.dll`.
  - The `FSR4/` directory serves as an immutable source repository. When a user selects a version, the corresponding DLL is copied only to the target game or global config (`gameconfig/...`), never modifying the source cache.
  - Selecting `"Latest"` copies `FSR4/Latest/amd_fidelityfx_upscaler_dx12.dll` back to the game or global config.
- **Config Persistence**: Persist the selected FSR version in `goverlay.vars` (`fsrversion=Latest`, `fsrversion=4.1.1b`, `fsrversion=4.0.2c`) and restore the selection in the UI upon loading.
- **Toggle Preservation**: Retain the independent "Force FSR4-i8" toggle switch controlling `Fsr4ForceEnableInt8` in `OptiScaler.ini`.

## Capabilities

### New Capabilities
- `optiscaler-fsr4-versions`: Specifies the FSR4 version selection combobox in the OptiScaler "Upscaler" sub-card, automated downloading of alternative builds (4.1.1b, 4.0.2c), removal of legacy `FSR4_LATEST` and `FSR4_INT8` folders, preservation of the pristine "Latest" DLL, and configuration persistence across game and global profiles.

## Impact

- Affected files:
  - `overlayunit.lfm` / `overlayunit.pas`: `fsrversionLabel`, `fsrversionComboBox`, removal of auto-hide logic in `fsrversionComboBoxChange`.
  - `optiscaler_tab.pas`: Reflow of "Upscaler" sub-card (`FOsSpatialSec`) to place `fsrversionLabel` and `fsrversionComboBox` below `preferredUpscalerComboBox`, with adjusters for subsequent toggles.
  - `optiscaler_update.pas`: Automated download of 4.1.1b and 4.0.2c DLLs to `~/.local/share/goverlay/FSR4/`, extraction and copy of native DLL to `FSR4/Latest/`, removal of `FSR4_LATEST` and `FSR4_INT8` creation and copying.
  - `overlay_config.pas`: Configuration loading, saving, and DLL deployment for all three FSR versions; synchronization with `goverlay.vars`; removal of legacy folder references.
  - `sidebar_nav.pas` / `bgmod_resources.pas` / `bgmod.lpr`: Profile sync and asset deployment honoring the central `FSR4/` directory; removal of legacy folder references.
  - `tests/gui/gui_test_cases.pas`: Automated GUI test coverage for combobox presence, item list, default selection, and persistence.
