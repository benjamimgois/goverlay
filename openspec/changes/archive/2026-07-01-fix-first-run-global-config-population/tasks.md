## 1. Refactor global initialization

- [x] 1.1 Extract the `gameconfig/global/` copy/sync block from `InitializeBGModDirectory` in `bgmod_resources.pas` into a new public helper `InitializeGlobalConfigDirectory`.
- [x] 1.2 Ensure `InitializeGlobalConfigDirectory` performs a full `cp -rf` when `gameconfig/global/bgmod` does not exist, and an `rsync` excluding user config files on subsequent runs.
- [x] 1.3 Remove the inline `gameconfig/global/` logic from `InitializeBGModDirectory` so it only prepares `bgmod/` and `.bgmod_original`.

## 2. Update startup sequence

- [x] 2.1 In `overlayunit.pas` form create, call `InitializeGlobalConfigDirectory` after `CheckAndInstallOptiScaler` finishes.
- [x] 2.2 Ensure `InitializeGlobalConfigDirectory` is still called when OptiScaler is already installed (so updates are synced on every start).

## 3. Verification

- [x] 3.1 Rebuild GOverlay and remove `~/.local/share/goverlay/gameconfig/global/` to simulate a first run.
- [x] 3.2 Start GOverlay and confirm that `gameconfig/global/` contains `OptiScaler.dll`, `libxess.dll`, plugins directory, and other runtime assets in addition to the wrapper scripts.
- [x] 3.3 Restart GOverlay and confirm that user config files in `gameconfig/global/` are preserved during the binary sync.
