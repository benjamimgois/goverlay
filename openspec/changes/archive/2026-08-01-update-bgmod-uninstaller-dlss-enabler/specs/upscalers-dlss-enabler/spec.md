# Capability: Upscalers Tab & DLSS Enabler Support

## MODIFIED Requirements

### Requirement: DLSS Enabler Downloading and Version Tracking
GOverlay SHALL download and extract the latest DLSS Enabler release from `https://github.com/bygalacos/OptiScalerBuilder` into `~/.local/share/goverlay/dlssenabler-edge`.
A `goverlay.vars` marker file containing `dlssenablerversion=<version>` SHALL be written inside the `dlssenabler-edge` directory.
The Software Status section on the Upscalers tab SHALL display the installed version of DLSS Enabler.
Global uninstallation via `bgmod-uninstaller --global` SHALL remove the `~/.local/share/goverlay/dlssenabler-edge` directory.

#### Scenario: Global uninstallation cleans DLSS Enabler cache
- **WHEN** user runs `bgmod-uninstaller --global`
- **THEN** system removes the `~/.local/share/goverlay/dlssenabler-edge` directory

### Requirement: Game Directory File Synchronization
When launching a game with DLSS Enabler active, `bgmod` SHALL copy `OptiScaler.ini`, the `OptiScaler/` directory, and copy root `OptiScaler.dll` renamed to the target proxy DLL (default `version.dll`) into the game executable directory.
`OptiScaler.ini` and `fakenvapi.ini` values SHALL be generated using the same configuration parameters as standard OptiScaler.
When uninstalling `bgmod` from a game directory, `bgmod-uninstaller` SHALL remove deployed proxy DLLs, configuration files, and the `OptiScaler/` subdirectory.

#### Scenario: Game directory uninstallation removes OptiScaler folder
- **WHEN** user runs `bgmod-uninstaller` in a game directory
- **THEN** system removes the `OptiScaler/` subdirectory and all deployed proxy DLLs
