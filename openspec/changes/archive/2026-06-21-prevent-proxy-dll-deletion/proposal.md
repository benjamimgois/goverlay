## Why

When `bgmod` (or `fgmod`) is executed to launch a game with OptiScaler active, or when GOverlay cleans up after disabling OptiScaler, it unconditionally deletes or backs up/renames all potential proxy DLLs (`dxgi.dll`, `winmm.dll`, etc.). This compromises third-party tools like Reshade that might be using these DLL files as their own proxy. GOverlay should only manage and modify the active proxy DLL selected by the user.

## What Changes

- Limit proxy DLL backups and updates to only the active proxy DLL (`DllName`) when OptiScaler is active.
- Prevent GOverlay from deleting inactive proxy DLL files during startup and cleanup unless they match GOverlay's master proxy files by size (indicating they were actually placed by GOverlay).
- Refactor the cleanup routine in `bgmod` and the `fgmod` script to implement this safe check.

## Capabilities

### New Capabilities
- `safe-proxy-dll-management`: Ensure only the active GOverlay proxy DLL is copied/backed up, and protect third-party proxy DLLs (like Reshade's `dxgi.dll`) from deletion during GOverlay cleanup/run.

### Modified Capabilities
<!-- None -->

## Impact

- Affected files: `bgmod.lpr` and `data/fgmod/fgmod`.
- Improved compatibility with Reshade, Special K, and other custom DLL injection wrappers.
