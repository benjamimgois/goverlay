# Spec Delta

## MODIFIED Requirements

### Requirement: Preservation of third-party proxy DLLs during game launch
The system SHALL NOT delete or overwrite any proxy DLL in the game directory that does not belong to GOverlay during game launch, cleanup, or proxy switching. Proxy ownership verification SHALL validate file size or payload signature against known GOverlay binaries rather than trusting unverified filename entries in configuration files.

#### Scenario: Launching game with d3d12 proxy when third-party dxgi proxy is present
- **WHEN** OptiScaler is configured with `DLL=d3d12.dll` and a third-party `dxgi.dll` (such as ReShade) exists in the game directory without a GOverlay backup
- **THEN** `bgmod` deploys `d3d12.dll`, skips deletion of `dxgi.dll`, and logs that the third-party proxy DLL is preserved.

#### Scenario: Switching OptiScaler proxy from dxgi to d3d12
- **WHEN** GOverlay previously deployed `dxgi.dll` (recorded as `ProxyDll=dxgi.dll`), and the configuration is updated to `DLL=d3d12.dll`
- **THEN** `bgmod` restores or deletes the previous GOverlay `dxgi.dll`, installs `d3d12.dll`, and updates `ProxyDll=d3d12.dll` in `goverlay.vars`.

#### Scenario: Third-party mod loader present with proxy DLL name
- **WHEN** a third-party mod loader (such as Cyber Engine Tweaks `version.dll` or RED4ext `winmm.dll`) is present in the game directory, and `bgmod.conf` contains matching `DLL=` but GOverlay never deployed that proxy for the game
- **THEN** `bgmod` verifies that the file does not match GOverlay's deployed proxy payload and skips deleting or overwriting the third-party file.

### Requirement: Safe uninstallation and cleanup of proxy DLLs
The uninstaller and disabled-cleanup routines SHALL only remove the proxy DLL that GOverlay actually installed, leaving all other proxy DLLs untouched. Cleanup of upscaler proxies SHALL NOT run when only ReShade is deployed.

#### Scenario: Uninstaller runs on game with third-party dxgi proxy
- **WHEN** `bgmod-uninstaller` runs for a game where GOverlay deployed `d3d12.dll` and a third-party `dxgi.dll` exists in the game directory
- **THEN** `bgmod-uninstaller` cleans up `d3d12.dll` (or restores its backup if one existed) and leaves `dxgi.dll` intact in the game directory.

#### Scenario: OptiScaler disabled in game configuration
- **WHEN** a game is launched with OptiScaler disabled after previously having OptiScaler installed
- **THEN** `bgmod` only cleans up the previously recorded proxy DLL and does not delete unrelated third-party proxy DLLs.

#### Scenario: Cleanup skipped when only ReShade is active
- **WHEN** a game is launched with ReShade enabled and OptiScaler disabled, and `goverlay.vars` contains only ReShade metadata (`reshadeproxy`)
- **THEN** `bgmod` bypasses OptiScaler proxy cleanup and does not delete any proxy DLLs in the game folder.
