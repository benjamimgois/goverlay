## Context

When clicking the Lossless Scaling tab, multiple blocking operations occur synchronously on the GUI thread:
1. `GetLsfgVkInstalledVersion` spawns `/bin/sh` with a piped chain of 4 package managers (`pacman`, `dpkg-query`, `rpm`).
2. `ReflowLosslessScalingTab` calls `ApplyThemeStyles`, which calls `UpdateDllStatus`, which calls `UpdateEngineStatus`, which calls `UpdateStatusCard`, which executes `GetLsfgVkInstalledVersion`.
3. `LoadLosslessConfig` and `losslessScalingTabSheetShow` call this sequence multiple times.
4. `DetectSteamLosslessDll` scans all Steam library paths unconditionally before checking existing config files.

## Goals / Non-Goals

**Goals:**
- Make switching to the Lossless Scaling tab instantaneous (< 20ms).
- Avoid running any blocking shell or package manager processes on the GUI thread.
- Break circular call chains between layout, styling, and status detection.
- Lazy-load Steam library detection only when no DLL path is configured.

**Non-Goals:**
- Rewriting the card layout or redesigning controls.
- Removing software version checks entirely (they remain accurate, just non-blocking).

## Decisions

### Decision 1: Direct JSON parsing for Vulkan layer version
- **Choice**: When checking `lsfg-vk`, parse `"implementation_version"` directly from the discovered layer JSON file (`VkLayer_LS_frame_generation.json` or `VkLayer_LSFGVK.json`).
- **Rationale**: Reading a 500-byte JSON file takes < 0.1ms and requires no external process or subshell.
- **Alternative considered**: Running package manager in a background thread. While possible, reading the JSON file directly provides the exact installed layer version immediately with zero process overhead.

### Decision 2: Break circular cascades in UI helper
- **Choice**:
  - `ReflowLosslessScalingTab` will only set bounds and positions of UI components.
  - `ApplyThemeStyles` will only apply widget colors and stylesheets; remove calls to `UpdateDllStatus`.
  - `UpdateDllStatus` will only validate the DLL file existence and style the edit/status label; remove call to `UpdateEngineStatus`.
  - `UpdateStatusCard` will be called once explicitly from `LoadLosslessConfig`.
- **Rationale**: Separating layout, styling, and state updates prevents exponential cascades and Qt stylesheet re-parsing.

### Decision 3: On-demand Steam DLL auto-detection
- **Choice**: Only call `DetectSteamLosslessDll` if `FLsDllPathEdit.Text` is empty after parsing `conf.toml`, `lsfg.toml`, and `bgmod.conf`.
- **Rationale**: If the game or global profile already has a configured DLL path, scanning multiple disk mounts is redundant.

### Decision 4: Safe background update synchronization
- **Choice**: In `TMakoCheckUpdateThread.SyncResult`, update `FLsEngineStatusLabel` and `FLsInstallBtn` directly without calling `ReflowLosslessScalingTab` or resetting `FCheckingUpdate` in a way that triggers duplicate threads.
- **Rationale**: Prevents infinite check loops and unnecessary re-layouts.

## Risks / Trade-offs

- [Risk] Vulkan layer JSON might omit `implementation_version` on non-standard manual builds.
  → Mitigation: If `implementation_version` is missing, display 'Installed' or run package query asynchronously as fallback.
