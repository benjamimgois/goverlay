## Context

GOverlay manages OptiScaler configurations and asset caches in `~/.local/share/goverlay/` (`optiscaler-stable` and `optiscaler-edge`). Game profiles store `OPT_CHANNEL` (0 for Stable, 1 for Bleeding-edge) and copy assets into `gameconfig/<Game>/`. On launch, the `bgmod` wrapper copies files into the game directory and synchronizes `OptiScaler.ini` bidirectionally based on file modification timestamps.

Users running custom forks (such as Multi-Frame Generation/MFG, neural rendering, or experimental upscalers) need to run unreleased builds without GOverlay attempting to update from GitHub or overwriting custom sections in `OptiScaler.ini`.

See `proposal.md` for background and motivation.

## Goals / Non-Goals

**Goals:**
- Provide a dedicated **"Custom Build"** channel slot (`OPT_CHANNEL=2`) in `optversionComboBox`.
- Support importing a custom OptiScaler build from any local directory into a centralized `optiscaler-custom/` cache.
- Validate that the selected directory contains `OptiScaler.dll` before importing.
- Inherit missing companion libraries (`amd_fidelityfx_*.dll`, `libxess.dll`, `fakenvapi.dll`, `bgmod` wrappers) from `optiscaler-stable/` automatically.
- Provide a conditional toggle **"In-game menu configuration only"** (`OPT_UNMANAGED_INI=1`), visible exclusively when Custom Build is selected.
- In unmanaged mode, prevent GOverlay and `bgmod` from overwriting `OptiScaler.ini` in the game directory.
- Provide a subtle notification (toast and status card hint) explaining library inheritance.

**Non-Goals:**
- Multi-build manager / unlimited custom named version profiles (reserved for future iterations if needed).
- Building or compiling OptiScaler forks from source inside GOverlay.
- Polling third-party or fork GitHub repositories for automated updates.

## Decisions

### Decision 1: Centralized Cache Directory (`optiscaler-custom/`)
- **Choice**: Copy selected custom files to `~/.local/share/goverlay/optiscaler-custom/` instead of referencing arbitrary paths directly.
- **Rationale**:
  - Full compatibility with Flatpak sandboxing (`XDG_DATA_HOME`).
  - Protects against broken symlinks or deleted user download directories.
  - Aligns with existing asset management architecture (`optiscaler-stable/`, `optiscaler-edge/`, `dlssenabler-stable/`).
- **Alternative considered**: Storing a direct directory path in `bgmod.conf`. Rejected due to Flatpak filesystem permission hurdles and fragile path lifetimes.

### Decision 2: Channel Value `OPT_CHANNEL=2`
- **Choice**: Map `optversionComboBox.ItemIndex = 2` to `OPT_CHANNEL=2` in `bgmod.conf`.
- **Rationale**: Reuses the integer channel convention (`0 = Stable`, `1 = Edge`, `2 = Custom`). Clean to serialize and parse in Pascal (`TIniFile`).

### Decision 3: Automatic Companion Library Fallback
- **Choice**: When importing, copy all files from the user directory, then inspect which companion libraries (`amd_fidelityfx_*.dll`, `libxess.dll`, `fakenvapi.dll`, `OptiPatcher.asi`, `bgmod` binaries) are absent and copy them from `optiscaler-stable/`.
- **Rationale**: Many community builds only compile a new `OptiScaler.dll` and `OptiScaler.ini`. If companion DLLs are not populated, the game would fail to load FSR/XeSS upscaling or wrapper scripts.

### Decision 4: Unmanaged INI Mode (`OPT_UNMANAGED_INI=1`)
- **Choice**:
  - Add a toggle `FUnmanagedIniToggle` to `optiscaler_tab.pas`, visible only when `optversionComboBox.ItemIndex = 2`.
  - When checked, serialize `OPT_UNMANAGED_INI=1` in `bgmod.conf`.
  - In `overlay_config.pas` (`SaveOptiScalerConfig`), skip rewriting `OptiScaler.ini` when `OPT_UNMANAGED_INI=1`.
  - In `bgmod.lpr` (`SyncOptiScalerIni`), skip timestamp comparison and never overwrite `GameDir/OptiScaler.ini` if it already exists.
- **Rationale**: Completely prevents GOverlay from overwriting in-game custom parameters (MFG, Neural Rendering, etc.).

### Decision 5: Non-Intrusive Guidance
- **Choice**: Show a 4-second toast notification when switching to or importing a Custom Build, plus a discreet italicized label under the channel selector.
- **Rationale**: Clearly informs users without modal interruptions or nag dialogs.

## Risks / Trade-offs

- **[Risk] User selects an invalid folder** → **Mitigation**: Check for `OptiScaler.dll` presence before copying. If missing, show a clear warning toast/dialog and abort without touching existing cache.
- **[Risk] `optiscaler-stable/` is empty when falling back** → **Mitigation**: Trigger `CheckAndInstallOptiScaler` first if stable cache is missing before copying fallbacks.
- **[Risk] User modifies in-game settings and expects GOverlay GUI to reflect them** → **Mitigation**: Visually dim GUI upscaler/framegen combo boxes and show a hint that settings are controlled directly in-game when unmanaged mode is enabled.
