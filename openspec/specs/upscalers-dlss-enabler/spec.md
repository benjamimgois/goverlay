# Capability: Upscalers Tab & DLSS Enabler Support

## Purpose

Provides integrated configuration, management, version tracking, and automated file deployment for OptiScaler and DLSS Enabler upscaling mods within GOverlay.

## Requirements

### Requirement: Tab Renaming and Card Layout Reorganization
The sidebar navigation item SHALL display the caption "Upscalers" instead of "OptiScaler".
The top section of the Upscalers tab SHALL render two 50% width cards side-by-side: "Upscaler" on the left and "GPU Driver" on the right.
The middle section SHALL render the "Options" card with 3 equal 33.3% width columns (`FOsOptiSec`, `FOsImgSec`, `FOsFakeSec`) spanning the full available width of the card.
The "Software Status" card SHALL be anchored to the bottom of the viewport area, and the "Options" card SHALL expand vertically to fill the remaining space between the top cards and "Software Status", eliminating empty unpainted background strips.

#### Scenario: Upscalers tab display and tab switching
- **WHEN** user launches GOverlay or switches between navigation tabs
- **THEN** system renders the Upscalers tab with full viewport height coverage, bottom-anchored Software Status card, and 3-column Options card without exposed background strips

### Requirement: Mutually Exclusive Image Checkboxes
The "Upscaler" card SHALL contain two mutually exclusive options: "OptiScaler" (selected by default) and "DLSS Enabler".
Each option SHALL be represented by an image logo.
The active option's image SHALL be displayed with full opacity (100%), and the inactive option's image SHALL be displayed with reduced opacity (40%).
When selecting "DLSS Enabler", if no custom proxy DLL is previously configured for the active game, `version.dll` SHALL be automatically pre-selected as the proxy DLL.

#### Scenario: Selecting DLSS Enabler image checkbox
- **WHEN** user selects DLSS Enabler option
- **THEN** DLSS Enabler image becomes 100% opaque, OptiScaler image becomes 40% opaque, and version.dll is pre-selected if no proxy was configured

### Requirement: DLSS Enabler Downloading and Version Tracking
GOverlay SHALL download and extract the latest DLSS Enabler release from `https://github.com/bygalacos/OptiScalerBuilder` into `~/.local/share/goverlay/dlssenabler-stable`.
GOverlay SHALL parse the release description body from `bygalacos/OptiScalerBuilder` to extract the specific `DLSS Enabler` version (e.g. `4.8.10.11`) and integrated `OptiScaler` version (e.g. `v0.10.0-pre1`) and write them to `dlssenabler-stable/goverlay.vars` as `dlssenablerversion` and `optiscalerversion`.
The Software Status section on the Upscalers tab SHALL display the parsed DLSS Enabler version and integrated OptiScaler version.
When DLSS Enabler is enabled (`UPSCALER_TYPE=1`), background update checking and manual update operations SHALL target the `bygalacos/OptiScalerBuilder` repository instead of standard OptiScaler channels, and the channel dropdown `optversionComboBox` SHALL select index 0 ("Stable Channel") and be disabled.
Global uninstallation via `bgmod-uninstaller --global` SHALL remove the `~/.local/share/goverlay/dlssenabler-stable` directory.

#### Scenario: Global uninstallation cleans DLSS Enabler cache
- **WHEN** user runs `bgmod-uninstaller --global`
- **THEN** system removes the `dlssenabler-stable` cache directory

#### Scenario: Parsing DLSS Enabler release versions
- **WHEN** GOverlay checks or downloads a release from `bygalacos/OptiScalerBuilder`
- **THEN** GOverlay parses the release body table to extract `DLSS Enabler` version (e.g. `4.8.10.11`) and integrated `OptiScaler` version (e.g. `v0.10.0-pre1`) and writes them into `goverlay.vars`

#### Scenario: Targeted update checking when DLSS Enabler is active
- **WHEN** DLSS Enabler is enabled and GOverlay checks for updates
- **THEN** GOverlay compares local `dlssenablerversion` against `bygalacos/OptiScalerBuilder` release tags and displays update status specifically for DLSS Enabler

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

### Requirement: Dynamic Frame Generation Options based on Selected Upscaler Mode
GOverlay SHALL update the items and tooltip descriptions of the `FG Input` (`fgInputComboBox`) and `FG Output` (`fgOutputComboBox`) comboboxes dynamically when the user switches between OptiScaler (`optiscalerRadioButton`) and DLSS-Enabler (`dlssenablerRadioButton`).

#### Scenario: OptiScaler mode selected
- **WHEN** user selects the OptiScaler mode radio button
- **THEN** `FG Input` combobox items SHALL be `['auto', 'nofg', 'dlssg', 'nukems', 'fsrfg', 'upscaler', 'fsrfg30']`
- **AND** `FG Output` combobox items SHALL be `['auto', 'nofg', 'fsrfg', 'xefg', 'nukems']`
- **AND** tooltips SHALL display OptiScaler-specific backend descriptions (`nukems` options).

#### Scenario: DLSS-Enabler mode selected
- **WHEN** user selects the DLSS-Enabler mode radio button
- **THEN** `FG Input` combobox items SHALL be `['auto', 'nofg', 'dlssg', 'nvngxfg', 'fsrfg', 'upscaler', 'fsrfg30']`
- **AND** `FG Output` combobox items SHALL be `['auto', 'nofg', 'fsrfg', 'xefg', 'nvngxfg', 'dlssg', 'dlssgwithnvngx']`
- **AND** tooltips SHALL display DLSS-Enabler-specific backend descriptions (`nvngxfg`, `dlssg`, `dlssgwithnvngx` options).

