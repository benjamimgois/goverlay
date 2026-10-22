## Why

When a user modifies OptiScaler configuration settings in-game via the OptiScaler overlay menu (such as selecting an upscaler backend, adjusting resolution scaling, or fine-tuning sharpness), OptiScaler writes the updated settings to `OptiScaler.ini` in the game directory. However, on subsequent game launches, the `bgmod` wrapper binary unconditionally overwrites `GameDir/OptiScaler.ini` with the stale/default template in `ConfigDir/OptiScaler.ini`, erasing all user in-game customizations (Issue #404).

## What Changes

- Implement bidirectional timestamp-based synchronization in `SyncOptiScalerIni` within `bgmod.lpr`:
  - When `GameDir/OptiScaler.ini` is newer than `ConfigDir/OptiScaler.ini` (`AgeGame > AgeConfig`), `bgmod` syncs the file back from `GameDir` to `ConfigDir`.
  - When `ConfigDir/OptiScaler.ini` is newer than `GameDir/OptiScaler.ini` (`AgeConfig > AgeGame`), `bgmod` syncs the file from `ConfigDir` to `GameDir`.
  - When `OptiScaler.ini` exists in only one directory, copy it to the other to initialize both.
  - When copying between directories, preserve the source file's modification timestamp (`mtime`) on the destination file to prevent unnecessary copies on subsequent launches.
  - Respect `PRESERVE_INI`: if set to `false`, force overwrite `ConfigDir` to `GameDir`.
- Also update `SyncFakeNvapiIni` to safely handle timestamps and avoid clobbering existing configuration.

## Capabilities

### New Capabilities
- `bgmod-sync-optiscaler`: Bidirectional and timestamp-aware synchronization of `OptiScaler.ini` and `fakenvapi.ini` between GOverlay's configuration directory and the game directory.

### Modified Capabilities
<!-- None -->

## Impact

- **Affected Files**: `bgmod.lpr`
- **Affected Systems**: `bgmod` launcher wrapper executed by Steam, Heroic, Lutris, or custom runners on game start.
- **Breaking Changes**: None. Backwards-compatible and preserves user settings both in-game and from the GOverlay GUI.
