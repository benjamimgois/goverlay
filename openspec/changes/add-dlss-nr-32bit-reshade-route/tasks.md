# Tasks

## 1. Detection

- [x] 1.1 Add `gapiDX8` (appended, so existing ordinals keep their values) and `d3d8.dll` import detection to `pe_utils.pas`.
- [x] 1.2 Add `DetectLegacyDirect3DApi`, which checks exe imports first and then scans modules next to the exe and one folder below, skipping GOverlay's and DLSS-NR's own folders and modules.

## 2. 32-bit runtime

- [x] 2.1 Add `GetBGModDlssNr32Path` (`dlss-nr-<arch>-i686`).
- [x] 2.2 Add `ParseDlssNr32Release`, `FetchDlssNr32Release` (releases list, fallback URL), `CheckAndInstallDlssNr32` and `IsDlssNr32Installed`.
- [x] 2.3 Download the i686 runtime after model extraction and at startup for existing installs (best effort).
- [x] 2.4 Keep the 64-bit RDNA3 download from taking the `i686-rdna3` asset.

## 3. Launcher

- [x] 3.1 Select the ReShade route for 32-bit Direct3D 8/9 games, and log a warning for other 32-bit games.
- [x] 3.2 Deploy the dx9 route by direct copies, with the manifest and `goverlay.vars` markers.
- [x] 3.3 Build `dlssnr-amd.ini` from the add-on ini with GOverlay settings, the network fallback and the default copy. Sync newer GOverlay settings on later launches.
- [x] 3.4 Copy DXVK's 32-bit `d3d8.dll` from the launching Proton for Direct3D 8 games.
- [x] 3.5 Export the `winevulkan`/`vulkan-1`/`d3d8` overrides and `WINE_D3D_CONFIG=renderer=gdi`.
- [x] 3.6 Skip GOverlay's ReShade deployment and remove its earlier proxy while the route is installed.
- [x] 3.7 Remove earlier installer and OptiScaler installs before deploying. Remove the route on disable, purge and in `bgmod-uninstaller`.

## 4. Tests

- [x] 4.1 Detection: exe imports, renderer module in a subfolder, newer API, own modules, depth limit.
- [x] 4.2 Release parsing: RDNA3 GitHub list with checksum and 64-bit assets, RDNA4 GitLab list, no i686 package.
- [x] 4.3 Direct3D 8 route: files, ini merge, manifest, markers, environment, up-to-date launch, settings sync, removal on disable.
- [x] 4.4 Direct3D 9 route: missing runtime, replacing installer/OptiScaler/ReShade installs, user `WINE_D3D_CONFIG`, `bgmod-uninstaller`.
- [ ] 4.5 Manual: Max Payne (Direct3D 8) and Space Marine (Direct3D 9) on RDNA3 with Proton-CachyOS.
- [ ] 4.6 Manual: an RDNA4 i686 package (asset name and layout not verified yet).
