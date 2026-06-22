# safe-proxy-dll-management

This capability ensures GOverlay's wrappers safely handle proxy DLLs (like `dxgi.dll`, `winmm.dll`, etc.) without deleting or interfering with third-party DLLs (such as those placed by Reshade).

## Requirements

### Requirement: Active proxy DLL backup and copy
When OptiScaler is active, GOverlay SHALL only back up, replace, and manage the active proxy DLL selected by the configuration (e.g., `dxgi.dll` or `winmm.dll`). It SHALL NOT rename, backup, or overwrite other inactive proxy DLLs present in the game directory.

#### Scenario: Enable OptiScaler with specific active proxy DLL
- **WHEN** GOverlay launches a game with OptiScaler enabled and DLL set to `winmm.dll`, and a third-party `dxgi.dll` is present in the game directory
- **THEN** GOverlay only backs up and overwrites `winmm.dll`, leaving the third-party `dxgi.dll` intact and running.

### Requirement: Safe cleanup of proxy DLLs
When disabling OptiScaler or performing file cleanup, GOverlay SHALL only delete proxy DLL files if they are verified to have been placed by GOverlay (either by matching the file size of the central GOverlay master proxy DLLs, or if a GOverlay backup `.b` file exists to be restored). Otherwise, the file SHALL be left intact.

#### Scenario: Disable OptiScaler with pre-existing third-party proxy DLL
- **WHEN** OptiScaler is disabled and cleanup runs, and a third-party `dxgi.dll` (which doesn't match GOverlay's master copy size and has no `.b` backup) is present
- **THEN** GOverlay does not delete `dxgi.dll`, preserving the third-party DLL.

#### Scenario: Disable OptiScaler with GOverlay-placed proxy DLL
- **WHEN** OptiScaler is disabled and cleanup runs, and `dxgi.dll` matches GOverlay's master copy size or has a `dxgi.dll.b` backup
- **THEN** GOverlay cleans it up by either restoring the backup or deleting the GOverlay-placed DLL.
