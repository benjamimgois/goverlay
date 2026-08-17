# optiscaler-persistence

## Purpose
Ensures that OptiScaler configurations, specifically `fakenvapi.ini` and `OptiScaler.ini`, are persistent and not overwritten by GOverlay on launch or update, and are parsed correctly.

## Requirements

### Requirement: Conditional fakenvapi.ini copy on startup
GOverlay SHALL only copy the template `fakenvapi.ini` from the cache folder to the global config folder on startup if the file does not already exist in the global config folder.

#### Scenario: Global fakenvapi.ini does not exist
- **WHEN** GOverlay starts up and `~/.local/share/goverlay/gameconfig/global/fakenvapi.ini` does not exist
- **THEN** GOverlay copies the template `fakenvapi.ini` to the global config folder.

#### Scenario: Global fakenvapi.ini already exists
- **WHEN** GOverlay starts up and `~/.local/share/goverlay/gameconfig/global/fakenvapi.ini` already exists
- **THEN** GOverlay does not copy or overwrite the existing `fakenvapi.ini`.

### Requirement: Robust case and whitespace-insensitive INI key parsing
GOverlay's INI configuration parser SHALL match and update keys and section headers in `OptiScaler.ini` in a case-insensitive and whitespace-insensitive manner, supporting section names passed with or without surrounding brackets (`[SectionName]` or `SectionName`), and inserting new keys at the end of existing sections without appending unbracketed section headers or duplicate lines.

#### Scenario: Load key with different casing and spaces
- **WHEN** the `OptiScaler.ini` file contains `dxgi = false` and the parser looks for `'Dxgi='`
- **THEN** the parser successfully matches the line and reads the value as `false`.

#### Scenario: Update key with different casing and spaces
- **WHEN** GOverlay saves the settings and updates a key (like `Dxgi=`) in an `OptiScaler.ini` file containing `dxgi = false`
- **THEN** the parser overwrites the existing `dxgi = false` line instead of appending a new one.

#### Scenario: Update key in section passed with or without brackets
- **WHEN** GOverlay saves FrameGen settings to `OptiScaler.ini` by calling `SetValue` with section `FrameGen` or `[FrameGen]`
- **THEN** the parser locates the existing `[FrameGen]` section header, updates or appends the key within `[FrameGen]`, and does not append unbracketed `FrameGen` headers to the end of the file.

#### Scenario: Creating a missing section header
- **WHEN** GOverlay saves settings to an INI file for a section header that does not yet exist
- **THEN** the parser creates a new section header with proper brackets `[SectionName]` followed by the key-value pair.

### Requirement: Seed fakenvapi.ini Template on Save if Absent
GOverlay SHALL copy the template `fakenvapi.ini` from the cache folder to the game configuration directory prior to updating keys when saving OptiScaler settings if `fakenvapi.ini` does not exist in the target directory.

#### Scenario: Saving OptiScaler settings when fakenvapi.ini is missing
- **WHEN** GOverlay saves OptiScaler settings and `fakenvapi.ini` does not exist in the active gameconfig directory
- **THEN** GOverlay seeds `fakenvapi.ini` from the cache folder before parsing and writing `force_reflex` or latency settings.

### Requirement: OptiScaler Fsr4Update default value set to auto
GOverlay SHALL write `Fsr4Update=auto` to `OptiScaler.ini` when saving OptiScaler settings with the Latest FSR version selected, and GOverlay SHALL parse both `Fsr4Update=auto` and `Fsr4Update=true` when loading OptiScaler settings to set the FSR version selection to Latest.

#### Scenario: Saving OptiScaler settings with Latest FSR version selected
- **WHEN** GOverlay saves OptiScaler settings with Latest FSR version selected (index 0)
- **THEN** GOverlay sets `Fsr4Update=auto` in `OptiScaler.ini`.

#### Scenario: Loading OptiScaler settings with Fsr4Update=true or auto
- **WHEN** GOverlay loads an `OptiScaler.ini` file containing `Fsr4Update=true` or `Fsr4Update=auto`
- **THEN** GOverlay selects the Latest FSR version (index 0) in the FSR version combobox.

### Requirement: OptiScaler Menu Scale auto default option and persistence
GOverlay SHALL provide `auto` as the first and default option in the `Menu scale` combobox on the Upscalers tab, write `Scale=auto` to the `[Menu]` section of `OptiScaler.ini` when `auto` is selected, and parse `Scale=auto` or missing/empty scale values as `auto` upon loading.

#### Scenario: Default Menu scale selection
- **WHEN** GOverlay loads default OptiScaler settings or creates a new configuration
- **THEN** the `Menu scale` combobox SHALL have `auto` selected by default.

#### Scenario: Saving OptiScaler settings with auto Menu scale selected
- **WHEN** user saves OptiScaler settings with `auto` selected in the `Menu scale` combobox
- **THEN** GOverlay SHALL write `Scale=auto` to the `[Menu]` section of `OptiScaler.ini`.

#### Scenario: Saving OptiScaler settings with numeric Menu scale selected
- **WHEN** user saves OptiScaler settings with `1.5` selected in the `Menu scale` combobox
- **THEN** GOverlay SHALL write `Scale=1.5` to the `[Menu]` section of `OptiScaler.ini`.

#### Scenario: Loading OptiScaler settings with Scale=auto
- **WHEN** GOverlay loads an `OptiScaler.ini` file containing `Scale=auto` or no `Scale` key
- **THEN** GOverlay SHALL select `auto` (index 0) in the `Menu scale` combobox.
