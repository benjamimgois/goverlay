## ADDED Requirements

### Requirement: Fallback load of default OptiScaler settings when missing
When GOverlay loads the OptiScaler configuration for a profile (global or game), if `OptiScaler.ini` does not exist in the profile's configuration directory, GOverlay SHALL load the configuration values from the default `OptiScaler.ini` file located in the active channel's cache folder (Stable or Edge depending on `OPT_CHANNEL` in `bgmod.conf`).

#### Scenario: Global OptiScaler.ini is missing on load
- **WHEN** the user opens the OptiScaler tab with the global profile active and `gameconfig/global/OptiScaler.ini` does not exist
- **THEN** GOverlay loads the default `ShortcutKey`, `Scale`, and checkbox values from the `OptiScaler.ini` file in the configured channel's cache folder, populating the GUI.

### Requirement: Seed default OptiScaler.ini template during configuration save
When saving the OptiScaler configuration, if the target `OptiScaler.ini` file does not exist in the profile's configuration directory, GOverlay SHALL copy the template `OptiScaler.ini` file from the active channel's cache folder to the destination directory before loading, modifying, and saving the updated user settings.

#### Scenario: Global OptiScaler.ini is missing on save
- **WHEN** the user saves the global OptiScaler configuration and `gameconfig/global/OptiScaler.ini` does not exist
- **THEN** GOverlay copies `OptiScaler.ini` from the active channel's cache folder into `gameconfig/global/` and then successfully saves the user's customized GUI selections to it.
