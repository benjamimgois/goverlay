# Proposal

## Why

Switching between the Global profile and per-game profiles causes in-memory state leakage and improper file deployment in GOverlay:
1. Frame interpolation state (such as AFMF) loaded in Global mode is retained in the singleton helper memory, causing false conflict popups when configuring upscalers on clean per-game profiles.
2. Clean game profiles without an existing `bgmod.conf` default to OptiScaler enabled (`UPSCALER_TYPE=0`) instead of None (`UPSCALER_TYPE=2`).
3. Toggling the Upscalers sidebar button unconditionally writes `GOVERLAY_OPTISCALER=1` to `bgmod.conf` even when the upscaler method is None (`UPSCALER_TYPE=2`), triggering `WINEDLLOVERRIDES` and launching orphaned proxy DLLs.
4. Leftover detection and uninstallation routines in `bgmod` and `bgmod-uninstaller` do not account for HelixSR binaries and directories (`HelixSR/`, `helixsr-fg`, `helixsr.ini`, and HelixSR proxy DLLs), allowing previously installed upscaler files to persist and execute in subsequent game launches.

## What Changes

- **Profile State Synchronization**: Automatically invoke `FLosslessScalingHelper.LoadLosslessConfig` whenever `FActiveGameName` changes (game selection in `games_tab.pas`, logo click in `overlayunit.pas`, and when entering the Upscalers module), ensuring the in-memory interpolation method matches the active profile.
- **Default Clean Profile to 'None'**: Ensure `LoadOptiScalerConfig` in `overlay_config.pas` defaults `UpscalerTypeItemIndex` to `2` (None) when `bgmod.conf` is missing or unconfigured.
- **Decouple Upscalers Toggle from Inactive Upscalers**: Update `SetGameToolEnabled` in `sidebar_nav.pas` so that enabling the Upscalers toggle only writes `GOVERLAY_OPTISCALER=1` if an active upscaler (`UPSCALER_TYPE <> 2`) is selected, and sets `GOVERLAY_LOSSLESS=1` only if an interpolation method (`INTERPOLATION_METHOD <> 'none'`) is active.
- **HelixSR Detection and Cleanup**: Enhance `HasOptiScalerLeftovers` in `bgmod.lpr` and file deletion routines in `bgmod-uninstaller.lpr` to detect, clean, and restore HelixSR assets (`HelixSR/`, `helixsr-fg/`, `helixsr.ini`, and HelixSR proxy DLLs) when upscalers are disabled or uninstalled.

## Capabilities

### Modified Capabilities
- `config-persistence-and-tool-toggling`: Clarify that activating tool toggles only exports runtime overrides when an underlying method is active, and ensure clean profiles default to inactive ('None') without retaining prior profile state.
- `safe-uninstall-backup-restore`: Expand leftover detection and uninstallation routines to include HelixSR direct loader and OptiScaler backend assets, ensuring orphan proxy DLLs are reliably cleaned up.

## Impact

- `overlayunit.pas`: Reset and reload `FLosslessScalingHelper` and `FOptiScalerHelper` during profile switches (`gamesLabelClick`, `GameCardClick`, and `optiscalerLabelClick`).
- `games_tab.pas`: Reload Lossless Scaling and OptiScaler tab states when activating a game profile.
- `overlay_config.pas`: Correct default initialization in `LoadOptiScalerConfig` for missing `bgmod.conf`.
- `sidebar_nav.pas`: Inspect active upscaler type and interpolation method before setting `GOVERLAY_OPTISCALER=1` and `GOVERLAY_LOSSLESS=1`.
- `bgmod.lpr` & `bgmod-uninstaller.lpr`: Add HelixSR folder, INI, and DLL detection to `HasOptiScalerLeftovers` and cleanup routines.
