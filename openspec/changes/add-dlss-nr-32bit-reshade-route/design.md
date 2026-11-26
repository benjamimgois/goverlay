# Design

## Route selection

bgmod chooses the ReShade route when all of these hold:

- DLSS-NR is the selected upscaler (`UPSCALER_TYPE=4`, OptiScaler enabled).
- The target is a Windows exe.
- The exe's PE Machine is i386.
- `DetectLegacyDirect3DApi` returns DirectX 8 or 9.

`DetectLegacyDirect3DApi` decides as follows:

1. If the exe imports `d3d8.dll` or `d3d9.dll`, that is the answer.
2. If the exe imports a newer API (DXGI/D3D11/D3D12/OpenGL), it is not a legacy game.
3. Otherwise it scans `*.dll` next to the exe and one folder below, at most 256 modules of at most 64 MiB each. It skips the folders GOverlay already skips, the route's own folders and modules (`dlssnr-amd`, `reshade-shaders`, `vk-override`, `ReShade32/64.dll`, `vulkan-1.dll`, `winevulkan.dll`), and the OptiScaler folders. It also skips DLLs named like a graphics runtime (`d3d8.dll`, `d3d9.dll`, `d3d10*.dll`, `d3d11.dll`, `d3d12*.dll`, `dxgi.dll`, `ddraw.dll`, `opengl32.dll`). Those are copies or wrappers, not the renderer: DXVK's `d3d8.dll`, which the route copies for Direct3D 8 games, imports `d3d9.dll`.
4. A module counts when it imports `d3d8.dll` or `d3d9.dll`. A module that imports no graphics API also counts when it loads Direct3D at run time (`LoadLibrary` and `GetProcAddress`). This is the case when its data names `d3d8.dll` and `Direct3DCreate8` (or `d3d9.dll` and `Direct3DCreate9`), in ASCII or UTF-16, and names no other graphics runtime. Hooking and wrapper tools such as DxWnd name every runtime and do not count. Only modules up to 16 MiB are read for this check.

A D3D8 module wins over a D3D9 one, because a D3D8 game needs `d3d8.dll` on top of what a D3D9 game needs. Max Payne is the motivating case. Neither its exe nor `e2driver/e2_d3d8_driver_mfc.dll` imports Direct3D: the exe loads the renderer module, and the module loads `D3D8.DLL` and `Direct3DCreate8` at run time. In a sweep of the 32-bit games in one Steam library, only Max Payne changed with the run-time check. Command & Conquer Red Alert II, whose `dxwnd.dll` names every runtime, stayed unknown.

A 32-bit game that is neither gets a log warning and keeps today's behaviour.

## Runtime

- **Location:** `dlss-nr-rdna3-i686` / `dlss-nr-rdna4-i686`, next to the 64-bit channel folders. It falls back to the other architecture with a warning, as the 64-bit channel does.
- **Version file:** `goverlay.vars` holds `OPTISCALER_DLSSNR_VERSION=<tag>`.
- **Release lookup:** GOverlay reads the releases list rather than "latest", because DLSSNR-RDNA3 also publishes releases without an i686 package. It takes the first `*.tar.gz` with `i686` in its name (with `rdna3` for RDNA3, without it for RDNA4). Checksum files are excluded.
- **Fallback URL:** `v0.0.9-linux-rdna3` / `v0.0.9` when the API cannot be reached.
- **Archive layout:** the tarball lists its files as `./…` and is extracted with one component stripped.

## Deployment

The deployment mirrors `install.sh`'s dx9 kind, by direct copies, as this spec requires.

1. **Earlier installs:** an earlier manual install is removed by its manifest. An earlier GOverlay OptiScaler install is purged.
2. **Copies:**
   - `dlssnr-amd/` from the runtime, plus the networks' weights from `dlss-nr-models` (see Derived networks) and, with the int4 weights, the int4 level folders.
   - Everything in `reshade/` and `vulkan/` except `dxgi.dll` and `ReShadePreset-d3d9.ini`, which is copied as `ReShadePreset.ini`.
   - `int4/reshade/*` over files of the same name: the int4 `dlssnr_amd.addon32`.
3. **`dlssnr-amd.ini`:** built from `ini/dlssnr-amd-addon.ini` as text, with comments and spacing kept.
   - `[RenoDX] Enabled = 1`, as `install.sh` sets it.
   - GOverlay's gameconfig `dlssnr-amd.ini` applied on top: `[Network]`, `[Preprocess]` and `[RenoDX]` take the same keys. NRHookPoint is skipped because it is OptiScaler-only. `[wilsjo2]` Passes/WorkingScale/SkinProtection go to `[DlssNr]`.
   - If the selected network's weights are missing, the game starts with `CC_SMALL_FP8`.
   - A copy is written to `dlssnr-amd/dlssnr-amd.default.ini`.
4. **DirectX 8:** DXVK's 32-bit `d3d8.dll` (checked to be i386) is copied from the first of:
   1. the Proton build that launches the game (the `proton` script in bgmod's arguments);
   2. the Proton build in `PROTONPATH` (umu-launcher: Heroic, Lutris, Faugus) or `STEAM_COMPAT_TOOL_PATHS` (Steam);
   3. the newest one installed (by modification time): Steam's `compatibilitytools.d` (native, Flatpak, `/usr/share/steam`), Proton builds named like Proton in every Steam library's `common/`, Lutris' and Heroic's Proton/Wine builds, and Lutris' and Heroic's DXVK releases (`x32/d3d8.dll`).

   A `d3d8.dll` already in the game folder (a d3d8to9 wrapper) is kept. A copy GOverlay made follows the build found at each launch, so Proton updates reach the game.
5. **Records:** the manifest `dlssnr-amd-install.txt` uses the installer's format, so either tool can remove the other's install. `goverlay.vars` gets `upscalertype=4`, `dlssnrroute=reshade-dx9`, `dlssnrruntime`, and `dlssnrapi`.

A later launch reinstalls when any of these is true:

- The route marker, manifest, or a core file is missing.
- The runtime version or Direct3D version changed.
- A model file's size changed.
- A DirectX 8 game lost its `d3d8.dll`.

The route is not installed (and an installed one is removed) when it cannot work and would only break the game:

- **`PROTON_USE_WINED3D=1`** (in the environment or the profile's `[Env]`): the game draws with wined3d, never reaches Vulkan, and `renderer=gdi` would leave it without 3D.
- **A DirectX 8 game with no DXVK `d3d8.dll`** in the game folder or anywhere above: the same, so the game keeps Wine's own Direct3D 8.

Otherwise the launch only applies GOverlay settings saved after the game's ini was written. Changes made in game are kept.

## Derived networks

DLSSNR-AMD ships three networks only as the difference from the models in the user's DLL. Its `install.sh` makes them at install, and GOverlay now does the same, once, in `dlss-nr-models`:

| Network | Made from | With |
|---|---|---|
| `CC_SMALL_FP8_EXPERIMENTAL` | `CC_SMALL_FP8.bin` (310.9.16 DLL only) | `python3 experimental/experimental_weights.py apply` and `experimental/dlssnr-small-experimental.delta` |
| `CC_SILVER_AARDWOLD_OPTIMIZED` | `CC_SILVER_AARDWOLD.bin` | `python3 optimized/experimental_weights.py apply` and `optimized/dlssnr-optimized.delta` |
| `CC_SILVER_AARDWOLD_OPTIMIZED_INT4` (its int4 layers' weights) | `CC_SILVER_AARDWOLD_OPTIMIZED.bin` | `int4/dlssnr-int4-weights` and the Ultra Performance tables in `int4/dlssnr-amd/int4-ultra`, which cover the other levels' |

- **When:** after model extraction, and in a background thread at every GOverlay start for models extracted earlier. That run checks the record and makes nothing once the networks are made. It is not part of the startup downloads, because GOverlay starts those only when a library is missing or an update is due. A lock keeps the start and an extraction from making the same files at once. Both are best effort, like the 32-bit runtime download.
- **Package files:** from the first runtime that has them, 64-bit runtimes first. The 64-bit and i686 packages carry the same difference files and checksums.
- **Checks:** each result is written to a `.part` file and kept only when its SHA-256 is the one in the package's `*.bin.sha256`. `derived-networks.vars` records that checksum, so later starts skip networks already made, and a new package's checksum makes them again.
- **Failure:** a network that cannot be made (no python3, a model from another DLL version, a non-x86-64 host for the int4 tool) is removed together with its record. A file made for an earlier package would not match the new package. The int4 weights go with `CC_SILVER_AARDWOLD_OPTIMIZED`, since they are made from it. The game greys the network out, and `EnsureDlssNrModelAvailable` starts a game set to it with `CC_SMALL_FP8`.
- **Deployment (both routes):** `SyncDlssNrNetworks` copies every network file in `dlss-nr-models` into the game's `dlssnr-amd/` when it is missing or its size differs. With the int4 weights it also copies the runtime's `int4/dlssnr-amd/{int4,int4-performance,int4-ultra}` without their restore tables (`*.fix.bin`, `*.mu.bin`): about 13 MiB per level. The ReShade route does this at install and on up-to-date launches, so networks made later arrive without a reinstall. The OptiScaler route does it after its file copy and on up-to-date launches. The files sit in `dlssnr-amd/`, which the manifest and the OptiScaler purge already remove.

## Environment

- **WINEDLLOVERRIDES:** `winevulkan=n,b`, `vulkan-1=n,b`, and `d3d8=n,b` for DirectX 8, without duplicating entries the user set. The OptiScaler proxy override and the DLSS-NR control layer are not exported for this route.
- **WINE_D3D_CONFIG:** `renderer=gdi`, appended to the user's value unless it already names a renderer.
- **int4 Vulkan layer:** when the game has the int4 weights and `dlssnr-amd/int4/layer`, `VK_ADD_LAYER_PATH` gets that folder and `VK_INSTANCE_LAYERS` gets `VK_LAYER_DLSSNR_int4`. Both are appended to the user's values. It is a native host layer (`.so`, 32- and 64-bit manifests) that turns on `VK_KHR_pipeline_binary` on the game's device, which the int4 layers need. It is exported whenever the weights are there, as in `install.sh`'s "every network can be switched to" line, so the network can be changed in game. The OptiScaler route needs no layer: its NR plugin adds the extension itself.

## Removal

The route is removed by its manifest, only when `goverlay.vars` has `dlssnrroute=reshade-dx9`. Entries that start with `/`, start with `..`, or contain `/..` are skipped. Removal happens:

- when DLSS-NR is turned off,
- when the upscaler changes,
- when the route no longer applies,
- in `bgmod-uninstaller`.

Before removal, logs are synced to GOverlay's central log folder.
