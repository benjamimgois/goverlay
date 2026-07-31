## Purpose
Allows users to import and load external `.conf` configuration files into GOverlay for MangoHud, vkBasalt, and vkSumi via the popup action menu.

## ADDED Requirements

### Requirement: Load External Configuration File
GOverlay SHALL provide a "Load config" option in the `popupBitBtn` action menu above "Save options" on the MangoHud, vkBasalt, and vkSumi tabs, allowing users to select and import external `.conf` configuration files.

#### Scenario: Select and load external MangoHud config
- **WHEN** the user selects "Load config" while on the MangoHud tab and picks a valid `.conf` file
- **THEN** GOverlay copies the selected configuration file to the active MangoHud configuration target, reloads the UI controls, and displays a success notification.

#### Scenario: Select and load external vkBasalt config
- **WHEN** the user selects "Load config" while on the vkBasalt tab and picks a valid `.conf` file
- **THEN** GOverlay copies the selected configuration file to `VKBASALTCFGFILE`, reloads the vkBasalt UI controls, and displays a success notification.

#### Scenario: Select and load external vkSumi config
- **WHEN** the user selects "Load config" while on the vkSumi tab and picks a valid `.conf` file
- **THEN** GOverlay copies the selected configuration file to `VKSUMICFGFILE`, reloads the vkSumi UI controls, and displays a success notification.

#### Scenario: Hide Load config on unsupported tabs
- **WHEN** the user opens the `popupBitBtn` menu on OptiScaler or Tweaks tabs
- **THEN** GOverlay hides the "Load config" menu item.
