## Context

GOverlay currently manages MangoHud, OptiScaler, vkBasalt, and vkSumi. Games launched through GOverlay use the `bgmod` wrapper to apply environment variables, manage proxy DLLs, and configure graphic mods. Users wanting ReShade on Linux/SteamOS previously relied on external plugins or manual file manipulation.

This design introduces native ReShade management into GOverlay, including automated runtime acquisition, shader pack management, tab UI placement, and Proton game injection.

## Goals / Non-Goals

**Goals:**
- Provide automated download and extraction of the official ReShade setup executable (with Add-on support) using 7z during splash screen.
- Verify ReShade binaries and default shaders in `HasMissingMandatoryLibraries`.
- Add a new "ReShade" tab under "Post processing" positioned as the first tab (`[ ReShade ] [ vkBasalt ] [ vkSumi ]`).
- Provide an intuitive shader collection manager for Standard Effects, SweetFX, qUINT, AstrayFX, and Prod80.
- Integrate with `bgmod` to deploy ReShade runtime DLLs, generate `ReShade.ini` with Wine path translation (`Z:\...`), configure `WINEDLLOVERRIDES`, and record proxy ownership in `goverlay.vars`.
- Harmonize ReShade with OptiScaler when both are active.

**Non-Goals:**
- Building or compiling ReShade from source.
- Rendering an in-app shader configurator (ReShade's interactive ImGui overlay handles effect adjustments in-game).
- Replacing or deprecating vkBasalt or vkSumi.

## Decisions

### 1. ReShade Distribution & Extraction
- **Choice**: Download official `ReShade_Setup_<version>_Addon.exe` and extract runtime DLLs (`ReShade64.dll`, `ReShade32.dll`) using `7z x -y`.
- **Rationale**: The Add-on build enables depth buffer access for advanced shaders (such as screen-space ray tracing / RTGI and ambient occlusion). 7z extraction is already implemented and reliable in GOverlay (`TOptiscalerTab.Extract7z`).
- **Storage**: Store binaries in `~/.local/share/goverlay/reshade/bin/` and shaders in `~/.local/share/goverlay/reshade/shaders/`.

### 2. UI Structure & Tab Ordering
- **Choice**: Create `reshadeTabSheet` dynamically in `overlayunit.pas` / `reshade_tab.pas` and set its `PageIndex := vkbasaltTabSheet.PageIndex`.
- **Rationale**: Satisfies the requirement that ReShade is the leftmost tab under "Post processing". When the user clicks "Post processing", `reshadeTabSheet` is active by default.
- **Card Layout**:
  - Status & Actions Card: ReShade version, status (Ready/Missing), Update/Re-install button, "Open Shaders Directory" button.
  - Shader Packages Card: Table or list of packs (Standard, SweetFX, qUINT, AstrayFX, Prod80) with status and Install/Remove/Update buttons.
  - Configuration Card: Overlay toggle hotkey selector, default proxy DLL selector (`dxgi.dll`, `d3d11.dll`, `d3d12.dll`, `d3d9.dll`, `opengl32.dll`), and multi-player warning for Add-on version.

### 3. Proton / Wine Path Translation
- **Choice**: Centrally host shaders and textures, and translate paths in `ReShade.ini` to Wine drive paths (`Z:\home\...`).
- **Rationale**: Avoids duplicating gigabytes of shaders into each game directory while allowing Proton's Windows runtime to access the files directly.
- **Implementation**: A helper `UnixPathToWinePath(const APath: string): string` converts `/` to `\` and prefixes `Z:`.

### 4. bgmod Integration & Proxy Tracking
- **Choice**: When launching a game with ReShade enabled:
  1. Determine target proxy DLL name (default `dxgi.dll`).
  2. If OptiScaler is also active with `dxgi.dll`: configure OptiScaler's `[ReShade]` section (`Path=ReShade64.dll`) and copy `ReShade64.dll` into the game directory. If proxy names differ (e.g. OptiScaler as `d3d12.dll` and ReShade as `dxgi.dll`), deploy both proxies.
  3. Deploy or template `ReShade.ini` in the game directory.
  4. Append proxy DLL to `WINEDLLOVERRIDES`.
  5. Record `reshadeproxy=<dll>` in `goverlay.vars` to ensure clean uninstallations and preserve non-GOverlay files.

## Risks / Trade-offs

- **[Risk]** ReShade download URL unavailable or changed.
  - **Mitigation**: Cache the installer locally; provide GitHub release mirror fallbacks.
- **[Risk]** 7z missing on stripped-down systems.
  - **Mitigation**: Check for `7z` executable via `FindDefaultExecutablePath('7z')`, logging an error and graceful notification if absent.
- **[Risk]** Add-on version flagging in anti-cheat protected multiplayer games.
  - **Mitigation**: Display a prominent notice in the ReShade tab advising users to use ReShade only in single-player or non-anti-cheat games.
