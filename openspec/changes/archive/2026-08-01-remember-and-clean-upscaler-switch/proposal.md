## Why

Currently, when switching between upscalers (OptiScaler and DLSS Enabler) for a game or global profile, `bgmod` does not automatically purge leftover files, proxy DLLs, and directories (such as `OptiScaler/`, `D3D12_OptiScaler/`, or `plugins/`) installed by the previously active upscaler. This can leave stale proxy DLLs or conflicting folders in the game directory.

By storing the active upscaler type in `bgmod.conf` (`UPSCALER_TYPE=0` or `1`) and tracking the installed upscaler in `goverlay.vars`, `bgmod` can detect when an upscaler switch occurs, clean up the previous upscaler files from the game directory while preserving original file backups in `BackupsDir`, and perform a fresh installation of the target upscaler.

## What Changes

- **Upscaler Switching Detection**: `bgmod` will compare the configured `UPSCALER_TYPE` (from `bgmod.conf`) against the installed upscaler type recorded in the game folder's `goverlay.vars`.
- **Automatic Cleanup on Switch**: When `bgmod` detects that the game directory contains a previously installed upscaler different from the currently configured one:
  - It purges all deployed proxy DLLs (such as `dxgi.dll`, `version.dll`, `winmm.dll`, etc.) and upscaler-specific files/directories (`OptiScaler/`, `D3D12_OptiScaler/`, `plugins/`, upscaler DLLs, logs, configs).
  - It leaves the per-game `BackupsDir` untouched so genuine game backup DLLs remain safely preserved.
  - It copies the files and proxy DLL for the newly selected upscaler.
- **Marker Persistence**: `bgmod` copies/writes `goverlay.vars` containing `upscalertype=<0|1>` alongside version info into the game folder upon installation.

## Capabilities

### New Capabilities

*(None)*

### Modified Capabilities

- `upscalers-dlss-enabler`: Extend `bgmod` execution requirements to detect upscaler type switches, clean up previous upscaler files, and preserve original backups.

## Impact

- `bgmod.lpr`: Core installation/synchronization logic will be updated to inspect `goverlay.vars` for `upscalertype` or upscaler version markers, trigger cleanup of former upscaler files when a switch is detected, and write `upscalertype` to `goverlay.vars`.
- Game directories will stay clean when switching between OptiScaler and DLSS Enabler without corrupting or losing original game backups.
