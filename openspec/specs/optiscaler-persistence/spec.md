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
GOverlay's INI configuration parser SHALL match and update keys in `OptiScaler.ini` in a case-insensitive and whitespace-insensitive manner.

#### Scenario: Load key with different casing and spaces
- **WHEN** the `OptiScaler.ini` file contains `dxgi = false` and the parser looks for `'Dxgi='`
- **THEN** the parser successfully matches the line and reads the value as `false`.

#### Scenario: Update key with different casing and spaces
- **WHEN** GOverlay saves the settings and updates a key (like `Dxgi=`) in an `OptiScaler.ini` file containing `dxgi = false`
- **THEN** the parser overwrites the existing `dxgi = false` line instead of appending a new one.
