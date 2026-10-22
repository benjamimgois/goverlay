# Tasks

## 1. OptiScaler Cleanup Gating and Marker Isolation

- [x] 1.1 Implement `HasOptiScalerLeftovers` helper in `bgmod.lpr` to gate cleanup on OptiScaler-specific markers (`proxydll`, `upscalertype`, `dlssenablerversion`, `fsrversion`, `OptiScaler.dll`, `fakenvapi.dll`) and bypass cleanup when only `reshadeproxy` exists; verify via unit/script test.
- [x] 1.2 Update the disabled-OptiScaler branch in `bgmod.lpr` (around L3525) to call `HasOptiScalerLeftovers` instead of generic `FileExists('goverlay.vars')`.

## 2. Vendor and Native Game DLL Protection

- [x] 2.1 Update `SafeCleanOrRestore` and the `OrigDlls` loop in `bgmod.lpr` and `bgmod-uninstaller.lpr` to ensure non-backed-up files (`sl.*.dll`, `nvngx_dlss*.dll`, `amd_fidelityfx_loader_dx12.dll`) are never deleted unless the file size matches the distributed payload in `SourceDir`.
- [x] 2.2 Verify that launching a mock game directory containing genuine `nvngx_dlss.dll` and `sl.dlss.dll` with ReShade active does not delete or modify those files.

## 3. Proxy Ownership Payload Verification

- [x] 3.1 Strengthen `IsGOverlayProxyFile` in `bgmod.lpr` to verify that candidate files matching `bgmod.conf` `DLL=` match GOverlay proxy payloads by size/hash before confirming ownership.
- [x] 3.2 Verify that a simulated third-party `version.dll` (e.g. Cyber Engine Tweaks) in a game directory is preserved when `DLL=version.dll` is in `bgmod.conf` and OptiScaler is disabled.

## 4. External Mod Folder and Launcher Path Matching

- [x] 4.1 Update `OptiScaler/` directory removal in `bgmod.lpr` and `bgmod-uninstaller.lpr` to check for `__folder_managed_by_vortex` or external mod markers before deleting the directory.
- [x] 4.2 Update launcher rule matching in `ResolveGameDirectory` in `bgmod.lpr` to support directory names with and without spaces (e.g. `Cyberpunk 2077` and `Cyberpunk2077`).

## 5. Compilation and Test Suite Validation

- [x] 5.1 Recompile `bgmod` and `bgmod-uninstaller` binaries and verify clean builds.
- [x] 5.2 Add test cases in `tests/gui/` or `tests/logic/` covering the ReShade-only launch scenario and DLSS/Streamline preservation, and verify all automated tests pass.
