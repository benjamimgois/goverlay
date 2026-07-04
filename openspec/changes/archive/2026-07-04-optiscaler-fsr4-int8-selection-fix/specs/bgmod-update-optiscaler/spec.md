## ADDED Requirements

### Requirement: Persist FSR version selection in variables file
When the user clicks Save in the OptiScaler configuration tab, GOverlay SHALL update the `fsrversion` key inside the game config folder's `goverlay.vars`. If the INT8 option "4.0.2c (INT8)" is selected, it SHALL write `fsrversion=4.0.2c INT8` to the file. If "Latest" is selected, it SHALL read the actual FSR version from the corresponding update channel cache's `goverlay.vars` file and write that version value (e.g. `4.1`) to the file.

#### Scenario: User saves INT8 selection
- **WHEN** the user selects "4.0.2c (INT8)" in the FSR Version combobox and clicks Save
- **THEN** GOverlay writes `fsrversion=4.0.2c INT8` to the game's `goverlay.vars` file.

#### Scenario: User saves Latest selection
- **WHEN** the user selects "Latest" in the FSR Version combobox and clicks Save
- **THEN** GOverlay reads `fsrversion` from the cache folder's `goverlay.vars` (e.g., `4.1`) and writes `fsrversion=4.1` to the game's `goverlay.vars` file.

### Requirement: Flexible FSR INT8 version formatting and UI refresh
When loading the FSR version from `goverlay.vars` or displaying the Software Status card, GOverlay SHALL recognize both `'4.0.2c (INT8)'` and `'4.0.2c INT8'` string formats as representing the INT8 version and select index `1` in the FSR Version combobox. Furthermore, when the configuration is saved, the Software Status card and labels SHALL refresh immediately.

#### Scenario: Loading vars file with INT8 without parentheses
- **WHEN** GOverlay loads settings for a game whose `goverlay.vars` contains `fsrversion=4.0.2c INT8`
- **THEN** GOverlay selects index 1 in the FSR Version combobox.

#### Scenario: Immediate status refresh on configuration save
- **WHEN** the user saves the configuration on the OptiScaler tab
- **THEN** GOverlay reloads the versions from `goverlay.vars` and refreshes the Software Status card labels immediately.

## MODIFIED Requirements

### Requirement: Copy OptiScaler assets only when toggle is enabled
When the user enables the OptiScaler toggle for a game (or global profile), GOverlay SHALL copy the OptiScaler files (DLLs, plugins, FSR4 folders, `fakenvapi.ini`, and `goverlay.vars`) from the configured channel's cache folder (`optiscaler-stable` or `optiscaler-edge`) to the target config directory. GOverlay SHALL then read the saved FSR version configuration from `goverlay.vars` for that game and overwrite `amd_fidelityfx_upscaler_dx12.dll` in the game's config directory with the correct version (Latest or INT8) from the cache channel subfolders.

#### Scenario: OptiScaler toggle enabled for a stable game
- **WHEN** the user enables the OptiScaler toggle for a game set to the stable channel
- **THEN** GOverlay copies all OptiScaler runtime files and `goverlay.vars` from `optiscaler-stable` to the game's config directory.

#### Scenario: OptiScaler toggle enabled for a bleeding-edge game
- **WHEN** the user enables the OptiScaler toggle for a game set to the bleeding-edge channel
- **THEN** GOverlay copies all OptiScaler runtime files and `goverlay.vars` from `optiscaler-edge` to the game's config directory.
