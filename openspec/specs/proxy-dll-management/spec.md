## Purpose

Manages the lifecycle, tracking, and safe cleanup of GOverlay proxy DLLs while strictly preserving third-party proxy DLLs (such as ReShade or SpecialK) in game directories.

## Requirements

### Requirement: Explicit tracking of deployed proxy DLLs
The system SHALL record the exact proxy DLL filename deployed for a game in the game directory's version metadata file (`goverlay.vars`) whenever OptiScaler or an upscaler proxy is installed.

#### Scenario: Installing OptiScaler with d3d12 proxy DLL
- **WHEN** OptiScaler is enabled for a game with `DLL=d3d12.dll`
- **THEN** `bgmod` deploys `d3d12.dll` and records `ProxyDll=d3d12.dll` in `goverlay.vars` in the game directory.

#### Scenario: Installing OptiScaler with dxgi proxy DLL
- **WHEN** OptiScaler is enabled for a game with `DLL=dxgi.dll`
- **THEN** `bgmod` deploys `dxgi.dll` and records `ProxyDll=dxgi.dll` in `goverlay.vars` in the game directory.

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

### Requirement: Mutual exclusion between ReShade and OptiScaler proxy DLLs
The system SHALL prevent ReShade and OptiScaler from concurrently using the same proxy DLL. If a user attempts to select a proxy DLL in either interface that is already in use by the other active tool, the selection SHALL be reverted to its previous valid index and a warning toast notification in English SHALL be displayed.

#### Scenario: User attempts to select conflicting proxy DLL in ReShade
- **WHEN** OptiScaler is active and using a proxy DLL (such as `dxgi.dll` or `d3d12.dll`), and the user selects the identical proxy DLL in the ReShade tab combobox
- **THEN** the system blocks the change, reverts the ReShade proxy combobox to its previous selection, does not save the configuration, and displays a warning toast indicating the DLL is already in use by OptiScaler.

#### Scenario: User attempts to select conflicting proxy DLL in OptiScaler
- **WHEN** ReShade is active and using a proxy DLL (such as `dxgi.dll` or `d3d12.dll`), and the user selects the identical proxy DLL in the OptiScaler tab combobox
- **THEN** the system blocks the change, reverts the OptiScaler proxy combobox to its previous selection, does not save the configuration, and displays a warning toast indicating the DLL is already in use by ReShade.

#### Scenario: Non-conflicting proxy selection
- **WHEN** OptiScaler is active on `version.dll` and the user selects `dxgi.dll` for ReShade
- **THEN** the selection is accepted, saved, and auto-saved without blocking.

### Requirement: Priority resolution dialog for dxgi proxy DLL
Because `dxgi.dll` supports both DirectX 11 and DirectX 12 games in ReShade while OptiScaler functions reliably with `version.dll`, when ReShade is activated or configured with `dxgi.dll` while OptiScaler is active on `dxgi.dll`, the system SHALL prompt the user with a confirmation dialog offering to switch OptiScaler to `version.dll`. OptiScaler SHALL only be considered active if its master feature toggle is enabled for the current profile.

#### Scenario: User confirms switching OptiScaler to version.dll
- **WHEN** OptiScaler is active with `dxgi.dll`, the user activates ReShade or selects `dxgi.dll` in ReShade, and confirms the dialog prompt
- **THEN** OptiScaler is automatically reconfigured to `version.dll`, OptiScaler's configuration is saved, ReShade is configured with `dxgi.dll`, and a success toast is displayed.

#### Scenario: User declines switching OptiScaler to version.dll
- **WHEN** OptiScaler is active with `dxgi.dll`, the user activates ReShade or selects `dxgi.dll` in ReShade, and declines the dialog prompt
- **THEN** OptiScaler remains on `dxgi.dll`, ReShade's proxy reverts to its previous setting or fallback `d3d11.dll`, and a warning toast explains that ReShade cannot use `dxgi.dll`.

#### Scenario: Activating OptiScaler when ReShade is already on dxgi.dll
- **WHEN** ReShade is active with `dxgi.dll` and the user activates OptiScaler via the method selector
- **THEN** OptiScaler defaults to `version.dll` instead of `dxgi.dll` to prevent collision, and an informative toast notification is displayed.

#### Scenario: ReShade configured with dxgi.dll while OptiScaler is disabled
- **WHEN** OptiScaler's master switch is disabled for the game, but the OptiScaler filename dropdown was previously set to `dxgi.dll`
- **AND** the user activates ReShade or selects `dxgi.dll` in the ReShade tab
- **THEN** the system accepts `dxgi.dll` for ReShade without displaying the proxy conflict resolution dialog, and does NOT enable or reconfigure OptiScaler.
