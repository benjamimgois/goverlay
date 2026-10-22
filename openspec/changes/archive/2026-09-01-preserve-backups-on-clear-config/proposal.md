## Why

When users click "Clear configuration" in the Home tab, GOverlay recursively deletes all configuration and data directories (`~/.local/share/goverlay`, `~/.config/goverlay`, and their Flatpak counterparts). However, original game DLL backups created during mod/upscaler installation (e.g., `amd_fidelityfx_dx12.dll`, `d3dcompiler_47.dll`, `nvngx.dll`) are stored under `~/.local/share/goverlay/gameconfig/<game>/backups/`. Deleting these folders permanently destroys the backups, preventing games from restoring original vendor DLLs if mods are uninstalled.

## What Changes

- Implement selective in-place directory cleaning for GOverlay data and config roots instead of unconditional recursive deletion (`DeleteDirectory`).
- Automatically detect and preserve any `backups/` directory containing backed up files along with its parent directory hierarchy (e.g. `gameconfig/<game>/backups/`).
- Prune empty `backups/` directories and directories that do not contain preserved backups.
- Update the Clear Configuration confirmation prompt (`rsClearConfigPrompt`) to clarify to the user that settings will be reset while game DLL backups are safely preserved.
- Add comprehensive logic unit tests covering directory cleanup with preserved backups, empty backup pruning, and non-backup deletion.

## Capabilities

### New Capabilities
- `clear-configuration`: Safe clearing of GOverlay configuration and data files while preserving game DLL backup folders.

### Modified Capabilities
<!-- No requirement changes to existing specs -->

## Impact

- `home_tab.pas`: `ClearConfigBtnClick` uses selective cleanup instead of blind `DeleteDirectory`.
- `configmanager.pas` / `apputils.pas` (or `overlay_config.pas`): Adds reusable recursive cleaning function with backup preservation (`CleanDirectoryPreservingBackups` / `ClearGOverlayConfigurationDirs`).
- `goverlay_strings.pas`: Updated confirmation string `rsClearConfigPrompt`.
- `tests/logic/logic_test_cases.pas`: New unit tests for safe config clearing and backup preservation.
