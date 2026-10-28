# Proposal

## Why

Following testing of the #445 regression fixes in real game environments (such as Cyberpunk 2077 launched via Epic Games / Heroic / umu), four critical edge-case issues were identified:
1. Game launcher substitution (`ResolveGameDirectory`) fails when launcher executables are invoked in lowercase (e.g., `redprelauncher.exe` vs `REDprelauncher.exe`), causing tools and configs to be deployed in the game root rather than the actual game binary directory.
2. `WINEDLLOVERRIDES` joins multiple DLL overrides with commas (`,`) instead of semicolons (`;`), causing Wine to treat appended DLLs (such as `dxgi=n,b`) as sub-options of the previous override, preventing Wine from overriding the DLL.
3. The Proxy DLL Conflict dialog checks whether the OptiScaler radio button is not "none" instead of checking if OptiScaler is actually enabled via its master switch, triggering false-positive conflict prompts when only ReShade is enabled, and subsequently re-enabling OptiScaler silently.
4. Launch arguments logged to `/tmp/bgmod.log` and central logs expose sensitive authentication tokens (such as `-AUTH_PASSWORD` exchange codes and `-epicuserid`).

Resolving these issues ensures reliable tool injection across different game stores and launchers while preserving user security and preventing unintentional tool activation.

## What Changes

- **Case-insensitive Launcher Substitution**: Update `ResolveGameDirectory` in `bgmod` and `bgmod-uninstaller` to use case-insensitive matching for both the game key and the target executable name.
- **Wine DLL Overrides Semicolon Delimiter**: Ensure `WINEDLLOVERRIDES` concatenation in `bgmod` uses semicolons (`;`) between distinct DLL rules rather than commas (`,`).
- **Active Tool Validation in Proxy DLL Conflict Handling**: Update `IsOptiScalerActive` and proxy conflict detection in GOverlay GUI to verify that OptiScaler is actually enabled in the active profile before warning about proxy DLL conflicts or auto-switching proxies.
- **Sensitive Launch Argument Redaction**: Implement redaction in `bgmod` for sensitive parameters (such as `-AUTH_PASSWORD`, `-AUTH_LOGIN`, tokens, and user IDs) prior to logging launch arguments to `/tmp/bgmod.log` and `~/.local/share/goverlay/logs/`.

## Capabilities

### New Capabilities
- `bgmod-launcher-resolution`: Governs case-insensitive game launcher executable matching and proper Wine DLL override environment variable syntax in `bgmod` and `bgmod-uninstaller`.

### Modified Capabilities
- `proxy-dll-management`: Update proxy conflict validation so that conflicts and resolution prompts between ReShade and OptiScaler are only evaluated when OptiScaler is actually enabled in the active profile.
- `centralized-tools-logging`: Add requirements for sensitive launch parameter redaction in `bgmod` logging outputs.

## Impact

- **Affected Code**: `bgmod.lpr`, `bgmod-uninstaller.lpr`, `overlayunit.pas`, `reshade_tab.pas`.
- **System Behavior**:
  - Games using launchers with differing casing (like Epic/Heroic `redprelauncher.exe`) will now resolve the correct target game directory.
  - Wine games with multiple proxy DLLs (e.g., ReShade `dxgi` alongside `d3dcompiler_47`) will correctly apply Wine DLL overrides for all specified DLLs.
  - ReShade configuration will not falsely alert on OptiScaler proxy collisions when OptiScaler is disabled, preventing accidental OptiScaler deployment.
  - Sensitive authentication tokens will no longer appear in plain text in world-readable `/tmp/bgmod.log` or central logs.
