## 1. Proxy DLL Deployment Tracking in bgmod

- [x] 1.1 In `bgmod.lpr`, record `proxydll=<DllName>` into `GameDir/goverlay.vars` upon installing the active proxy DLL and verify the key is written.
- [x] 1.2 In `bgmod.lpr`, refactor `IsGOverlayProxyFile` to perform two-tier verification: read `proxydll` from `goverlay.vars` first, and fallback to comparing file size against candidate OptiScaler DLLs from cache/source paths if `proxydll` is unset. Verify third-party proxy DLLs return false.

## 2. Uninstaller Proxy DLL Cleanup Parity

- [x] 2.1 In `bgmod-uninstaller.lpr`, update `IsGOverlayProxyFile` and cleanup logic with the identical two-tier verification and verify third-party proxy DLLs are skipped during uninstallation.

## 3. Compilation and Regression Testing

- [x] 3.1 Add regression test verifying that a third-party `dxgi.dll` (e.g. simulated ReShade DLL) is preserved when OptiScaler runs with `d3d12.dll` and when uninstalled.
- [x] 3.2 Recompile `bgmod` and `bgmod-uninstaller`, refresh binaries in `data/bgmod/`, and run `make test` to verify all tests pass.
