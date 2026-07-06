## Why

Uninstalling OptiScaler from a game that has the bleeding-edge channel installed leaves proxy DLLs (`dxgi.dll`, `version.dll`, `winmm.dll`, `dbghelp.dll`, `wininet.dll`, `winhttp.dll`) behind in the game directory. The game runs OptiScaler even after uninstall because the proxy DLL remains loaded. The root cause: `bgmod-uninstaller` and `bgmod` (launch-wrapper cleanup path) use `IsGOverlayProxyFile`, which size-compares the proxy DLL in `GameDir` against the global pristine `bgmod/renames/<name>.dll` (always stable). When the game was installed via the bleeding-edge channel, its proxy DLL came from `gameconfig/<game>/renames/<name>.dll`, which has a different size than the stable template, so the size check fails and the DLL is treated as a third-party proxy and skipped.

Additionally, in global mode, all configuration tabs (except EnvVars/Tweaks) display the old path `"~/.local/share/goverlay/bgmod/bgmod"` for the launcher in the launch command preview instead of the active global profile path `"~/.local/share/goverlay/gameconfig/global/bgmod"`. Furthermore, MangoHud's save and remove routines incorrectly target the template configuration path `bgmod/bgmod.conf` instead of the active global profile configuration `gameconfig/global/bgmod.conf`.

## What Changes

- **Marker-based ownership ownership**: `IsGOverlayProxyFile` SHALL treat any proxy DLL (as identified by `IsProxyDllName`) without a `.b` backup as a GOverlay-owned file when a `goverlay.vars` file exists in the same game directory. The `goverlay.vars` file is already copied to the GameDir by `bgmod` on every OptiScaler install, so its presence is a reliable signature that GOverlay installed the proxy DLLs regardless of channel/version.
- **Remove fragile size-comparison path**: the size check against `bgmod/renames/<name>.dll` and `bgmod/OptiScaler.dll` SHALL be removed from `IsGOverlayProxyFile` in both `bgmod-uninstaller.lpr` and `bgmod.lpr`. It was a stable-only heuristic that breaks for any channel whose proxy DLL has a different size.
- **Preserve third-party safety when no marker**: when `goverlay.vars` is absent in the GameDir, proxy DLLs without a `.b` backup SHALL continue to be treated as third-party (not GOverlay-owned) and left alone, so users who manually placed ReShade/other proxy DLLs are not affected.
- **Global profile wrapper path**: when in global mode, the launcher preview and generated launch commands for MangoHud, vkBasalt, vkSumi, and OptiScaler SHALL point to the active global profile `~/.local/share/goverlay/gameconfig/global/bgmod` instead of the template `bgmod/bgmod.conf` folder or `bgmod/bgmod` path.
- **MangoHud global config path**: in global mode, MangoHud's save and remove routines SHALL write and remove settings directly to the active global profile `gameconfig/global/bgmod.conf` instead of writing to the template `bgmod/bgmod.conf`.

## Capabilities

### New Capabilities

_None._

### Modified Capabilities

- `fix-optiscaler-game-uninstall-cleanup`: the wrapper-cleanup and uninstaller requirements gain a marker-based ownership detection rule so cleanup reliably removes GOverlay-owned proxy DLLs across all OptiScaler channels (stable and bleeding-edge), instead of relying on a size comparison that only works for the stable template.
- `fix-global-bgmod-launch-path`: all configuration tabs correctly display the global profile wrapper path and write to the correct global config files in global mode.

## Impact

- **Affected files**: `bgmod-uninstaller.lpr`, `bgmod.lpr`, `overlay_config.pas`, `overlayunit.pas`.
- **APIs & Paths**: none — the function signatures and call sites stay the same; only the internal ownership logic and global path constructions change.
- **Build**: the `bgmod` and `bgmod-uninstaller` binaries must be rebuilt and shipped updated copies into `data/bgmod/`.
- **Compatibility**: existing stable installs continue to uninstall cleanly (the `goverlay.vars` marker is present there too). Games that had a failed uninstall leaving edge proxy DLLs behind will now uninstall correctly on the next uninstall run because the marker is already present alongside the leftover DLLs.
- **Risks**: none identified — utilizing the global profile directory for launch wrappers is already standard for the EnvVars tab and is the intended behavior for all other tabs.