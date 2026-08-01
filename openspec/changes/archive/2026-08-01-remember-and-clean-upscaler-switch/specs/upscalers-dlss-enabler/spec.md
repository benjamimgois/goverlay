# Capability: Upscalers Tab & DLSS Enabler Support

## MODIFIED Requirements

### Requirement: Game Directory File Synchronization
When launching a game via `bgmod`, `bgmod` SHALL detect if the upscaler currently installed in the game executable directory (recorded in `goverlay.vars`) differs from the upscaler type configured in `bgmod.conf` (`UPSCALER_TYPE`).
When `bgmod` detects an upscaler type switch (or a disabled upscaler state with leftovers), it SHALL remove all previously deployed proxy DLLs, upscaler DLLs, configuration files, log files, and upscaler directories (`OptiScaler/`, `D3D12_OptiScaler/`, `plugins/`) from the game directory while keeping the original game backup files inside `BackupsDir` intact.
When launching a game with DLSS Enabler active, `bgmod` SHALL copy `OptiScaler.ini`, the `OptiScaler/` directory, root `OptiScaler.dll` renamed to the target proxy DLL (default `version.dll`), and supporting libraries into the game executable directory, and update `goverlay.vars` with `upscalertype=1` and version information.
When launching a game with OptiScaler active, `bgmod` SHALL copy `OptiScaler.ini`, `D3D12_OptiScaler/` (or `plugins/` if present), root pre-renamed or fallback proxy DLL, and supporting libraries into the game executable directory, and update `goverlay.vars` with `upscalertype=0` and version information.
`OptiScaler.ini` and `fakenvapi.ini` values SHALL be generated using the same configuration parameters regardless of the active upscaler.
When uninstalling `bgmod` from a game directory, `bgmod-uninstaller` SHALL remove deployed proxy DLLs, configuration files, and upscaler subdirectories (`OptiScaler/`, `D3D12_OptiScaler/`, `plugins/`).

#### Scenario: Game directory uninstallation removes OptiScaler folder
- **WHEN** user runs `bgmod-uninstaller` in a game directory
- **THEN** system removes the `OptiScaler/` subdirectory, `D3D12_OptiScaler/` subdirectory, `plugins/` subdirectory, and all deployed proxy DLLs

#### Scenario: Switching from OptiScaler to DLSS Enabler cleans game directory
- **WHEN** a game directory contains a previous OptiScaler installation and `bgmod` runs with DLSS Enabler configured (`UPSCALER_TYPE=1`)
- **THEN** `bgmod` removes previous OptiScaler proxy DLLs and folders, preserves `BackupsDir` backups intact, installs DLSS Enabler files, and writes `upscalertype=1` to `goverlay.vars`

#### Scenario: Switching from DLSS Enabler to OptiScaler cleans game directory
- **WHEN** a game directory contains a previous DLSS Enabler installation and `bgmod` runs with OptiScaler configured (`UPSCALER_TYPE=0`)
- **THEN** `bgmod` removes previous DLSS Enabler proxy DLLs and the `OptiScaler/` folder, preserves `BackupsDir` backups intact, installs OptiScaler files, and writes `upscalertype=0` to `goverlay.vars`
