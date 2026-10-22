## Why

Switching to the "Lossless Scaling" tab currently takes several seconds or noticeably lags, unlike other tabs which appear instantly. This delay is caused by synchronous external shell calls (`pacman`/`dpkg`/`rpm`) executed on the main GUI thread, circular cascade chains between `ReflowLosslessScalingTab`, `ApplyThemeStyles`, `UpdateDllStatus`, and `UpdateStatusCard`, and unconditional Steam library scans.

## What Changes

- **Non-blocking layer version detection**: Parse `implementation_version` directly from the already-located Vulkan layer JSON file (`VkLayer_LS_frame_generation.json`) instead of blocking the GUI thread with synchronous shell/package manager calls (`pacman`/`dpkg`/`rpm`).
- **Decouple layout and styling from status detection**: `ReflowLosslessScalingTab` and `ApplyThemeStyles` must only update geometry and stylesheets; they must not call `UpdateDllStatus`, `UpdateEngineStatus`, or `UpdateStatusCard`.
- **Eliminate redundant call chains**: Call `UpdateStatusCard` exactly once when loading the tab.
- **On-demand Steam DLL detection**: Only run `DetectSteamLosslessDll` if the DLL path is empty and not already specified in the configuration file or TOML profile.
- **Prevent background thread re-trigger loops**: In `TMakoCheckUpdateThread.SyncResult`, update the UI directly without re-triggering another full cascade that re-spawns the thread.

## Capabilities

### Modified Capabilities
- `lossless-scaling-config`: Add requirements for non-blocking software status detection and instantaneous tab switching without GUI thread stalls.

## Impact

- `lossless_scaling_tab.pas`: `GetLsfgVkInstalledVersion`, `ReflowLosslessScalingTab`, `ApplyThemeStyles`, `UpdateDllStatus`, `UpdateEngineStatus`, `LoadLosslessConfig`, and `TMakoCheckUpdateThread`.
- `overlayunit.pas`: `losslessScalingTabSheetShow` and event handling deduplication.
- No breaking changes to existing config schemas or saved user profiles.
