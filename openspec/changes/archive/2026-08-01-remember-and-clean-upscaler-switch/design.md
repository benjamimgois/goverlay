## Context

See `proposal.md` for motivation. Currently `bgmod.lpr` handles OptiScaler and DLSS Enabler file deployment. `bgmod.conf` already records `UPSCALER_TYPE=0` (OptiScaler) or `UPSCALER_TYPE=1` (DLSS Enabler). `goverlay.vars` tracks versions.

## Goals / Non-Goals

**Goals:**
- Detect when `goverlay.vars` in `GameDir` indicates an installed upscaler different from the currently configured `UPSCALER_TYPE` in `bgmod.conf`.
- Purge all previous upscaler proxy DLLs, folders (`OptiScaler/`, `D3D12_OptiScaler/`, `plugins/`), and binaries when a switch is detected before installing the new upscaler.
- Preserve `BackupsDir` untouched during upscaler switches so genuine game DLL backups are never lost or overwritten with proxy files.
- Persist `upscalertype=0` or `upscalertype=1` in `goverlay.vars` in `GameDir` upon installation.

**Non-Goals:**
- Modifying the GUI tabs or layout (the Upscalers tab already contains the selector radiobuttons/checkboxes).
- Changing how `bgmod-uninstaller` operates during global uninstallation.

## Decisions

### 1. Upscaler Type Detection via `goverlay.vars` and `bgmod.conf`
- **Choice**: Read `UPSCALER_TYPE` from `bgmod.conf` (target) and inspect `goverlay.vars` in `GameDir` for `upscalertype` or version keys (`dlssenablerversion` vs `optiscalerversion`).
- **Rationale**: `goverlay.vars` is the authoritative marker written by `bgmod` into `GameDir` after every install. Comparing target `UPSCALER_TYPE` against `goverlay.vars` unambiguously detects if an upscaler switch occurred.

### 2. Unconditional Previous Upscaler Cleanup on Switch
- **Choice**: When target `UPSCALER_TYPE` differs from installed upscaler type in `goverlay.vars`:
  - Run a complete purge of upscaler files: delete proxy DLLs (`dxgi.dll`, `version.dll`, `winmm.dll`, `dbghelp.dll`, `wininet.dll`, `winhttp.dll`, `d3d12.dll`), upscaler DLLs, logs, configs, `OptiScaler/`, `D3D12_OptiScaler/`, and `plugins/`.
  - Do NOT touch `BackupsDir` (which holds the genuine original game DLL backups).
- **Rationale**: Keeps the game directory clean and prevents proxy DLL conflicts (e.g. `dxgi.dll` leftover when switching to `version.dll`).

### 3. Writing `upscalertype` to `goverlay.vars`
- **Choice**: When `bgmod` or GOverlay writes `goverlay.vars`, include `upscalertype=0` or `upscalertype=1`.
- **Rationale**: Provides explicit fast-path checking in `NeedsGameDirUpdate` / `bgmod`.

## Risks / Trade-offs

- **[Risk]** Third-party proxy DLL deleted on upscaler switch.  
  **Mitigation**: `IsGOverlayProxyFile` checks for GOverlay proxy ownership before deleting any proxy DLL.
