## Purpose

Manages the lifecycle, tracking, and safe cleanup of GOverlay proxy DLLs while strictly preserving third-party proxy DLLs (such as ReShade or SpecialK) in game directories.

## ADDED Requirements

### Requirement: Explicit tracking of deployed proxy DLLs
The system SHALL record the exact proxy DLL filename deployed for a game in the game directory's version metadata file (`goverlay.vars`) whenever OptiScaler or an upscaler proxy is installed.

#### Scenario: Installing OptiScaler with d3d12 proxy DLL
- **WHEN** OptiScaler is enabled for a game with `DLL=d3d12.dll`
- **THEN** `bgmod` deploys `d3d12.dll` and records `ProxyDll=d3d12.dll` in `goverlay.vars` in the game directory.

#### Scenario: Installing OptiScaler with dxgi proxy DLL
- **WHEN** OptiScaler is enabled for a game with `DLL=dxgi.dll`
- **THEN** `bgmod` deploys `dxgi.dll` and records `ProxyDll=dxgi.dll` in `goverlay.vars` in the game directory.

### Requirement: Preservation of third-party proxy DLLs during game launch
The system SHALL NOT delete or overwrite any proxy DLL in the game directory that does not belong to GOverlay during game launch, cleanup, or proxy switching.

#### Scenario: Launching game with d3d12 proxy when third-party dxgi proxy is present
- **WHEN** OptiScaler is configured with `DLL=d3d12.dll` and a third-party `dxgi.dll` (such as ReShade) exists in the game directory without a GOverlay backup
- **THEN** `bgmod` deploys `d3d12.dll`, skips deletion of `dxgi.dll`, and logs that the third-party proxy DLL is preserved.

#### Scenario: Switching OptiScaler proxy from dxgi to d3d12
- **WHEN** GOverlay previously deployed `dxgi.dll` (recorded as `ProxyDll=dxgi.dll`), and the configuration is updated to `DLL=d3d12.dll`
- **THEN** `bgmod` restores or deletes the previous GOverlay `dxgi.dll`, installs `d3d12.dll`, and updates `ProxyDll=d3d12.dll` in `goverlay.vars`.

### Requirement: Safe uninstallation and cleanup of proxy DLLs
The uninstaller and disabled-cleanup routines SHALL only remove the proxy DLL that GOverlay actually installed, leaving all other proxy DLLs untouched.

#### Scenario: Uninstaller runs on game with third-party dxgi proxy
- **WHEN** `bgmod-uninstaller` runs for a game where GOverlay deployed `d3d12.dll` and a third-party `dxgi.dll` exists in the game directory
- **THEN** `bgmod-uninstaller` cleans up `d3d12.dll` (or restores its backup if one existed) and leaves `dxgi.dll` intact in the game directory.

#### Scenario: OptiScaler disabled in game configuration
- **WHEN** a game is launched with OptiScaler disabled after previously having OptiScaler installed
- **THEN** `bgmod` only cleans up the previously recorded proxy DLL and does not delete unrelated third-party proxy DLLs.
