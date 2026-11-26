# Proposal

## Why

DLSS-NR in GOverlay uses DLSSNR-AMD's OptiScaler route. That route exists only in the 64-bit (x86_64) package, so DLSS-NR cannot work in 32-bit games: GOverlay copies 64-bit OptiScaler files into the game folder, the 32-bit game cannot load them, and nothing happens. Old 32-bit DirectX 8 and DirectX 9 games (Max Payne, Warhammer 40,000: Space Marine) are a large part of what people want to run DLSS-NR on.

DLSSNR-AMD's 32-bit (i686) package has a route for these games: `reshade-feeder-dx9`. DXVK turns Direct3D 8/9 into Vulkan. A Vulkan loader placed in the game folder then loads ReShade32 as a Vulkan layer, and ReShade runs the DLSS-NR add-on (`dlssnr_amd.addon32`). Installed by hand with the package's `install.sh`, this works in Max Payne (DirectX 8) and Space Marine (DirectX 9) under Proton, with two additions:

- **DirectX 8:** DXVK's `d3d8.dll` in the game folder with a `d3d8=n,b` override. Proton otherwise draws Direct3D 8 with wined3d over OpenGL, where the Vulkan layer never loads.
- **Both:** `WINE_D3D_CONFIG=renderer=gdi`. Wine draws some things with wined3d itself (DirectDraw, video playback, dxdiagn). With ReShade in the same process, wined3d's OpenGL context makes ReShade recurse into `wglCreateContext` until the stack overflows (Max Payne's intro videos). Its Vulkan renderer creates a short-lived instance that the add-on attaches to and that is then destroyed (Space Marine: "Invalid physicalDevice"). The game itself draws with DXVK, so wined3d needs no 3D renderer.

GOverlay's network list also offers DLSSNR-AMD's derived networks, `CC_SMALL_FP8_EXPERIMENTAL` and `CC_SILVER_AARDWOLD_OPTIMIZED`, but GOverlay never made their weights. The package ships them only as differences from the models in the user's DLL, which its `install.sh` applies at install. So in both routes the add-on greyed them out in game ("needs the model of the 310.9.16 nvngx_dlssnr.dll", "its weights were not made at install"), even with the right DLL.

## What Changes

- **Download:** GOverlay also downloads the i686 package of the selected architecture into `dlss-nr-<arch>-i686`. This happens after model extraction and, for existing installs, at startup.
- **Route selection:** bgmod uses the ReShade route instead of the OptiScaler route when DLSS-NR is selected and the game is 32-bit and draws with Direct3D 8 or 9. Direct3D is detected from the exe's imports, or else from a DLL next to it or one folder below that imports Direct3D or loads it at run time, since old games often load Direct3D from a renderer module. Max Payne's renderer module loads `d3d8.dll` at run time and imports no Direct3D.
- **Deployment:**
  - bgmod copies the files `install.sh` copies for the dx9 route: the runtime folder and models, `reshade/` and `vulkan/` without `dxgi.dll`, the D3D9 preset as `ReShadePreset.ini`, and the int4 add-on.
  - It writes `dlssnr-amd.ini` from the package's add-on ini with GOverlay's DLSS-NR settings applied.
  - For DirectX 8 it copies DXVK's 32-bit `d3d8.dll`: from the Proton build that launches the game, else the one named by `PROTONPATH` or `STEAM_COMPAT_TOOL_PATHS`, else the newest installed Proton or DXVK build (Steam, Lutris, Heroic). The copy follows Proton updates.
  - It installs nothing when the route cannot work: under `PROTON_USE_WINED3D=1`, or in a DirectX 8 game with no DXVK `d3d8.dll` to be found.
  - It lists everything in `dlssnr-amd-install.txt`, in the installer's own format.
- **Environment:** bgmod exports `winevulkan`, `vulkan-1` (and, for DirectX 8, `d3d8`) as `n,b` overrides. It adds `renderer=gdi` to `WINE_D3D_CONFIG` unless the user already set a renderer.
- **ReShade:** GOverlay's own ReShade deployment is skipped in these games, and a ReShade proxy it installed earlier is removed. The route already runs ReShade, and two copies would hook the game twice.
- **Cleanup:** the route is removed by its manifest when DLSS-NR is turned off, when another upscaler is chosen, and by `bgmod-uninstaller`. An install made by `install.sh`, and a 64-bit OptiScaler install from before, are removed when GOverlay installs the route.
- **Derived networks:** GOverlay makes `CC_SMALL_FP8_EXPERIMENTAL`, `CC_SILVER_AARDWOLD_OPTIMIZED` and the weights of `CC_SILVER_AARDWOLD_OPTIMIZED`'s int4 layers once into `dlss-nr-models`, using the package's own difference files and tools, after model extraction and at startup. It keeps each only when its SHA-256 matches the package's. bgmod copies them, with the int4 level folders, into the game in both routes. On the ReShade route it exports the int4 Vulkan layer, as `install.sh`'s launch line does.
- **32-bit asset filter fix:** the 64-bit RDNA3 runtime download no longer takes the `i686-rdna3` asset of the same release.

## Capabilities

### Modified Capabilities

- `dlss-nr-runtime-management`: 32-bit runtime download, route selection for 32-bit DirectX 8/9 games, ReShade-route deployment, environment, and cleanup.

## Impact

- `pe_utils.pas`: `gapiDX8`, `DetectLegacyDirect3DApi`.
- `bgmod.lpr`: route detection, deployment, settings sync, environment, cleanup, ReShade interplay.
- `bgmod-uninstaller.lpr`: manifest-based removal of the route.
- `bgmod_resources.pas`: `GetBGModDlssNr32Path`.
- `optiscaler_update.pas`: `ParseDlssNr32Release`, `FetchDlssNr32Release`, `CheckAndInstallDlssNr32`, `IsDlssNr32Installed`, the download after model extraction, the RDNA3 asset filter fix, and `MakeDlssNrDerivedNetworks`/`EnsureDlssNrDerivedNetworks`.
- `overlayunit.pas`: startup download of the 32-bit runtime and making of the derived networks for existing DLSS-NR installs.
- `bgmod.lpr` (both routes): `SyncDlssNrNetworks` copies the derived networks and int4 level folders; the ReShade route exports the int4 Vulkan layer.
- `tests/logic/`: detection (including run-time loading), release parsing, deployment, settings sync, cleanup, uninstaller, derived networks.

## Non-goals

- Making the derived networks without the package's tools: GOverlay runs its `experimental_weights.py` (python3, which model extraction already needs) and its x86-64 `dlssnr-int4-weights`. A network that cannot be made stays greyed out in game, and a game set to start with it starts with `CC_SMALL_FP8`.
- 32-bit games that draw with OpenGL, DirectX 10/11 or DirectDraw. bgmod logs a warning for them.
- Proton's own DXVK D3D8 switches (`PROTON_DXVK_D3D8`, GE's `PROTON_ENABLE_D8VK`). Copying DXVK's `d3d8.dll` works the same across Proton builds.
