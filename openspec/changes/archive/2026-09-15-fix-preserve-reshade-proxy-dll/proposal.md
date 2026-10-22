## Why

When users run games with third-party modding tools like ReShade (which commonly deploys as `dxgi.dll`) alongside OptiScaler configured to use an alternate proxy DLL (such as `d3d12.dll`), GOverlay's `bgmod` execution wrapper and `bgmod-uninstaller` delete the third-party proxy DLL during startup cleanup or uninstallation.

This occurs because `IsGOverlayProxyFile` currently checks only whether the target filename is a proxy DLL name (`dxgi.dll`, `winmm.dll`, etc.) and whether `goverlay.vars` exists in the game directory. Since `goverlay.vars` is always placed in the game directory when GOverlay manages that game, any third-party proxy DLL is falsely identified as GOverlay-owned and deleted.

## What Changes

- Track the specific proxy DLL deployed by GOverlay in `goverlay.vars` (e.g. `ProxyDll=d3d12.dll` or `ProxyDll=dxgi.dll`) upon OptiScaler installation.
- Refactor `IsGOverlayProxyFile` in both `bgmod.lpr` and `bgmod-uninstaller.lpr` to verify that the target proxy DLL was actually installed by GOverlay:
  - Check whether the recorded `ProxyDll` in `goverlay.vars` matches the target file name.
  - As an additional safeguard, verify whether the file size matches the deployed OptiScaler proxy DLL from the active channel or fallback paths, preventing false positives if `goverlay.vars` has no recorded proxy or was modified.
- Ensure that inactive proxy DLL cleanup in `bgmod` skips deletion of third-party proxy DLLs that do not belong to GOverlay.
- Add test coverage verifying that third-party proxy DLLs (like ReShade's `dxgi.dll`) are preserved when OptiScaler runs with an alternate DLL (such as `d3d12.dll`).

## Capabilities

### New Capabilities
- `proxy-dll-management`: Manages lifecycle, tracking, and safe cleanup of GOverlay proxy DLLs while strictly preserving third-party proxy DLLs (such as ReShade) in game directories.

### Modified Capabilities
- None

## Impact

- `bgmod.lpr`: `IsGOverlayProxyFile`, `ProxyDlls` cleanup loop, and proxy DLL installation tracking.
- `bgmod-uninstaller.lpr`: `IsGOverlayProxyFile` and uninstaller proxy cleanup logic.
- `bgmod`: Recompiled binaries in `data/bgmod/` and build outputs.
- Test suites: Adds regression test validating preservation of third-party proxy DLLs during game launch and cleanup.
