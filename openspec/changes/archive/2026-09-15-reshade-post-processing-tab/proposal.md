## Why

Currently, GOverlay offers post-processing controls via vkBasalt and vkSumi, but users wanting to use ReShade on Linux/SteamOS must rely on external third-party plugins (like LetMeReShade for Steam Deck) or manually configure DLL overrides and shader paths. By introducing native ReShade management into GOverlay, users can easily configure ReShade, download shader packages (Standard, SweetFX, qUINT, AstrayFX, Prod80), manage game-level injection via `bgmod`, and seamlessly combine ReShade with upscalers (like OptiScaler) without manual Wine configuration or fragile log parsing.

## What Changes

- **Startup Splash Screen Download**: Automatically download the official ReShade setup executable (with Add-on support) at runtime, extract runtime binaries (`ReShade64.dll`, `ReShade32.dll`) via `7z`, and download the Standard Shaders repository into `~/.local/share/goverlay/reshade/`.
- **New ReShade Tab**: Add a dedicated "ReShade" tab under the "Post processing" navigation menu, positioned as the leftmost tab before `vkBasalt` (`[ ReShade ] [ vkBasalt ] [ vkSumi ]`).
- **Shader Package Manager**: Provide an in-tab shader manager to install, update, or remove popular shader collections (Standard Effects, SweetFX, qUINT/Marty's Mods, AstrayFX, Prod80) with a single click, plus a button to open the local shaders directory.
- **Runtime Configuration & Game Integration (`bgmod`)**: Support per-game ReShade enablement, proxy DLL selection (`dxgi.dll`, `d3d11.dll`, `d3d12.dll`, `d3d9.dll`, `opengl32.dll`), overlay toggle key selection, automatic `ReShade.ini` generation with Wine path translation (`Z:\home\...`), and co-existence with OptiScaler.
- **Proxy Tracking**: Record deployed ReShade proxies in `goverlay.vars` to ensure clean uninstallations and prevent clobbering user-installed standalone files.

## Capabilities

### New Capabilities
- `reshade-post-processing`: Covers the new ReShade tab interface under Post processing, shader collection installation/management, configuration persistence, and `bgmod` runtime proxy deployment/Wine path mapping for games.

### Modified Capabilities
- `startup-libraries-verification`: Extends startup verification to check for ReShade runtime binaries and standard shaders alongside OptiScaler and companion libraries during application startup.

## Impact

- **UI**: `sidebar_nav.pas` and `overlayunit.pas` - clicking "Post processing" displays `[ ReShade ] [ vkBasalt ] [ vkSumi ]` with ReShade active by default.
- **New Unit**: `reshade_tab.pas` for building and reflowing the ReShade tab cards and handling shader downloads.
- **Startup Download**: `optiscaler_update.pas` and `overlayunit.pas` - `HasMissingMandatoryLibraries` and `TStartupDownloadThread` include `CheckAndInstallReShade`.
- **Runtime (`bgmod.lpr`)**: Deploys `ReShade64.dll` and generates `ReShade.ini` for Proton games when ReShade is enabled, sets `WINEDLLOVERRIDES`, and records `reshadeproxy` in `goverlay.vars`.
- **Dependencies**: Uses `7z` (already used by OptiScaler extraction) and `curl`/native download routines.
