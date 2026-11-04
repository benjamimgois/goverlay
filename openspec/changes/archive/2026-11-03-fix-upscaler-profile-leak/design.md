# Design

## Context

See `proposal.md` for background and motivation. GOverlay relies on tab helpers (`TLosslessScalingTabHelper`, `TOptiScalerTabHelper`, `TMangoHudUiHelper`) instantiated as singletons on `Tgoverlayform`. When switching between the Global profile (`FActiveGameName = ''`) and specific game profiles (`FActiveGameName <> ''`), tab helpers retain their in-memory fields unless an explicit reload is performed. Additionally, `bgmod` and `sidebar_nav.pas` coordinate tool activation and file cleanup using flags in `bgmod.conf` and markers in the game folder.

## Goals / Non-Goals

**Goals:**
- Eliminate in-memory state leakage between Global and game profiles for frame interpolation (AFMF, LSFG, MAKO) and upscalers (OptiScaler, DLSS Enabler, HelixSR, DLSS-NR).
- Ensure new or cleaned profiles default to upscaler disabled (`UPSCALER_TYPE=2`) and frame interpolation disabled (`INTERPOLATION_METHOD=none`).
- Prevent `SetGameToolEnabled` from activating `GOVERLAY_OPTISCALER=1` in `bgmod.conf` when the upscaler method is set to None.
- Ensure `bgmod` and `bgmod-uninstaller` recognize HelixSR companion directories and direct loaders as GOverlay mod artifacts, safely removing them when upscalers are disabled or uninstalled.

**Non-Goals:**
- Refactoring the entire singleton architecture of GOverlay or unifying all tab helpers into a monolithic store.
- Changing the internal options or algorithm settings of AFMF, LSFG-VK, or HelixSR themselves.

## Decisions

### 1. Centralize Profile State Reload on Profile Navigation
- **Choice**: Call `FLosslessScalingHelper.LoadLosslessConfig` and `FOptiScalerHelper.LoadOptiScalerConfig` whenever `FActiveGameName` is modified in `overlayunit.pas` (`gamesLabelClick`) and `games_tab.pas` (`GameCardClick`), as well as during `optiscalerLabelClick`.
- **Rationale**: Currently, `LoadLosslessConfig` is only triggered when `losslessScalingTabSheetShow` executes. If a user was on Global with AFMF and switches to a game, entering Upscalers opens the OptiScaler sub-tab by default without refreshing `FLosslessScalingHelper`. Reloading on profile context switch guarantees that `FLosslessScalingHelper.InterpolationMethod` always reflects the active profile's `bgmod.conf`.
- **Alternatives considered**: Checking the conflict against disk directly in `optiscalerRadioButtonClick`. Rejected because UI controls in the Frame Interpolation tab would still show stale radio buttons.

### 2. Explicit Default for Clean Profiles in `LoadOptiScalerConfig`
- **Choice**: In `overlay_config.pas:LoadOptiScalerConfig`, explicitly assign `Settings.UpscalerTypeItemIndex := 2;` (None) in the default initialization block.
- **Rationale**: `FillChar(Settings, SizeOf(Settings), 0)` zero-initializes the record. If `bgmod.conf` is missing (a brand-new or cleaned profile), `UpscalerTypeItemIndex` stayed `0` (OptiScaler), falsely showing OptiScaler as active and saving `GOVERLAY_OPTISCALER=1` on subsequent operations.
- **Alternatives considered**: Defaulting to `0` (OptiScaler). Rejected because clean profiles should start in a clean, disabled state until the user explicitly selects an upscaler.

### 3. Couple Sidebar Upscalers Toggle with Method Selection
- **Choice**: In `sidebar_nav.pas:SetGameToolEnabled`, when `AToolIdx = 2` (Upscalers) is toggled on:
  - Read `UPSCALER_TYPE` and `INTERPOLATION_METHOD` from the profile's `bgmod.conf`.
  - Set `GOVERLAY_OPTISCALER=1` only if `UPSCALER_TYPE <> 2`.
  - Set `GOVERLAY_LOSSLESS=1` only if `INTERPOLATION_METHOD <> 'none'` and not empty.
- **Rationale**: Previously, toggling Upscalers ON wrote `GOVERLAY_OPTISCALER=1` unconditionally. If the user had None selected, `bgmod` still exported `WINEDLLOVERRIDES=dxgi=n,b` and injected or kept leftover proxy DLLs.

### 4. Comprehensive HelixSR Detection and Cleanup in `bgmod` & Uninstaller
- **Choice**: In `bgmod.lpr:HasOptiScalerLeftovers` and `bgmod-uninstaller.lpr`, add checks for:
  - `DirectoryExists(GamePath + 'HelixSR')`
  - `DirectoryExists(GamePath + 'helixsr-fg')`
  - `FileExists(GamePath + 'helixsr.ini')`
  When purging disabled upscalers or running uninstallation, delete `HelixSR/`, `helixsr-fg/`, `helixsr.ini`, and remove proxy DLLs matching `goverlay.vars` or default proxy names (`dxgi.dll`).
- **Rationale**: HelixSR in Native DLSS mode replaces `dxgi.dll` and adds `nvngx.dll` and `helixsr-fg`. The previous cleanup only looked for `OptiScaler.dll` and `OptiScaler.ini`, leaving HelixSR proxy DLLs behind as "third-party proxy DLLs".

## Risks / Trade-offs

- [Risk] Calling `LoadLosslessConfig` and `LoadOptiScalerConfig` on game click may slightly increase card click latency → [Mitigation] Both configuration files are tiny INI files (< 2KB), resulting in sub-millisecond parsing times.
- [Risk] Deleting `dxgi.dll` during cleanup could affect user-installed third-party wrappers → [Mitigation] The existing backup system in `BackupsDir` ensures that any original file present prior to GOverlay deployment is preserved and restored.
