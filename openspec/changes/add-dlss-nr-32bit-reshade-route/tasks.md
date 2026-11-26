# Tasks

## 1. Detection

- [x] 1.1 Add `gapiDX8` (appended, so existing ordinals keep their values) and `d3d8.dll` import detection to `pe_utils.pas`.
- [x] 1.2 Add `DetectLegacyDirect3DApi`, which checks exe imports first and then scans modules next to the exe and one folder below, skipping GOverlay's and DLSS-NR's own folders and modules.
- [x] 1.3 Count a module that loads `d3d8.dll`/`d3d9.dll` at run time (Max Payne's renderer module imports no Direct3D), unless it names several graphics runtimes. Skip DLLs named like a graphics runtime.

## 2. 32-bit runtime

- [x] 2.1 Add `GetBGModDlssNr32Path` (`dlss-nr-<arch>-i686`).
- [x] 2.2 Add `ParseDlssNr32Release`, `FetchDlssNr32Release` (releases list, fallback URL), `CheckAndInstallDlssNr32` and `IsDlssNr32Installed`.
- [x] 2.3 Download the i686 runtime after model extraction and at startup for existing installs (best effort).
- [x] 2.4 Keep the 64-bit RDNA3 download from taking the `i686-rdna3` asset.

## 3. Launcher

- [x] 3.1 Select the ReShade route for 32-bit Direct3D 8/9 games, and log a warning for other 32-bit games.
- [x] 3.2 Deploy the dx9 route by direct copies, with the manifest and `goverlay.vars` markers.
- [x] 3.3 Build `dlssnr-amd.ini` from the add-on ini with GOverlay settings, the network fallback and the default copy. Sync newer GOverlay settings on later launches.
- [x] 3.4 Copy DXVK's 32-bit `d3d8.dll` for Direct3D 8 games: launching Proton, then `PROTONPATH`/`STEAM_COMPAT_TOOL_PATHS`, then the newest installed Proton or DXVK build. Refresh the copy when it changes.
- [x] 3.4a Install nothing under `PROTON_USE_WINED3D=1` or in a Direct3D 8 game without a DXVK `d3d8.dll`.
- [x] 3.5 Export the `winevulkan`/`vulkan-1`/`d3d8` overrides and `WINE_D3D_CONFIG=renderer=gdi`.
- [x] 3.6 Skip GOverlay's ReShade deployment and remove its earlier proxy while the route is installed.
- [x] 3.7 Remove earlier installer and OptiScaler installs before deploying. Remove the route on disable, purge and in `bgmod-uninstaller`.

## 4. Tests

- [x] 4.1 Detection: exe imports, renderer module in a subfolder, newer API, own modules, depth limit.
- [x] 4.1a Detection: Direct3D loaded at run time (ASCII and UTF-16 names), a hooking tool that names every runtime, DXVK's `d3d8.dll` in the game folder.
- [x] 4.2 Release parsing: RDNA3 GitHub list with checksum and 64-bit assets, RDNA4 GitLab list, no i686 package.
- [x] 4.3 Direct3D 8 route: files, ini merge, manifest, markers, environment, up-to-date launch, settings sync, removal on disable.
- [x] 4.3a DXVK `d3d8.dll` lookup: none found, `PROTONPATH`, newest installed build across Steam libraries and Lutris (64-bit and non-Proton files ignored), `PROTON_USE_WINED3D`, refresh after a Proton update.
- [x] 4.4 Direct3D 9 route: missing runtime, replacing installer/OptiScaler/ReShade installs, user `WINE_D3D_CONFIG`, `bgmod-uninstaller`.
- [x] 4.4a Keep the suite off the network: the model-extraction test provides a stub i686 runtime, and the missing-runtime test hides both architectures' runtimes, since bgmod falls back to the other one.
- [x] 4.4b Derived networks: making, checksum record, made once, newer package, missing model; copies and int4 folders on both routes, a network made after the route was installed, the int4 layer on the ReShade route and none without its weights.
- [x] 4.5 Manual: Max Payne (Direct3D 8) and Space Marine (Direct3D 9) on RDNA3 (RX 7800 XT) with Proton-CachyOS: route installed over an `install.sh` install and a 64-bit OptiScaler install, DXVK `d3d8.dll` from the launching Proton, add-on loaded, Max Payne's intro videos play, removal on disable leaves the game's own files intact.
- [ ] 4.6 Manual: an RDNA4 i686 package (asset name and layout not verified yet).
- [ ] 4.7 Manual: the derived networks and the int4 levels in game. Done: making them from real 310.9.16 models matched the package's three checksums; Max Payne and Space Marine list every network as available and serve `CC_SMALL_FP8_EXPERIMENTAL` with the int4 layer exported. Max Payne also starts with `CC_SMALL_FP8_EXPERIMENTAL`. Open: `CC_SILVER_AARDWOLD_OPTIMIZED`'s int4 levels in game, and a 64-bit game.

## 5. Derived networks

- [x] 5.1 Add `MakeDlssNrDerivedNetworks`/`EnsureDlssNrDerivedNetworks`: the package's tools and difference files into `.part` files, SHA-256 check, `derived-networks.vars`, removal of networks that cannot be made, int4 weights from `CC_SILVER_AARDWOLD_OPTIMIZED`.
- [x] 5.2 Make them after model extraction and in a background thread at every start (not in the startup downloads, which run only when something is missing), one at a time.
- [x] 5.3 Copy the networks and int4 level folders (without restore tables) into the game in both routes (`SyncDlssNrNetworks`), at install and on up-to-date launches.
- [x] 5.4 Export the int4 Vulkan layer on the ReShade route when the int4 weights are installed.
