## Why

Users who already have custom, manually created configuration files (`.conf`) for MangoHud, vkBasalt, or vkSumi (such as custom ReShade shader setups or tuned performance presets) currently have no direct way to load them into GOverlay. To use custom files, users must manually copy and paste file contents into GOverlay's configuration directory, which can easily be overwritten when saving settings. Adding a "Load config" option directly inside GOverlay's action menu makes it seamless to import existing `.conf` files.

## What Changes

- Add a new "Load config" menu item (`loadconfigMenuItem`) inside `popsaveMenu` (the popup menu attached to `popupBitBtn`), positioned immediately above "Save options".
- Implement `loadconfigMenuItemClick` event handler that prompts a file dialog (`TOpenDialog`) to select an external `.conf` file.
- Depending on the active tab:
  - **MangoHud tab**: Imports the selected `.conf` file into the active MangoHud configuration target and reloads the UI via `LoadMangoHudConfig`.
  - **vkBasalt tab**: Imports the selected `.conf` file into `VKBASALTCFGFILE` and reloads the UI via `LoadVkBasaltConfig`.
  - **vkSumi tab**: Imports the selected `.conf` file into `VKSUMICFGFILE` and reloads the UI via `LoadVkSumiConfig`.
- Display a success notification to the user upon loading the configuration file.

## Capabilities

### New Capabilities
- `load-custom-config`: Allows users to import external `.conf` files into GOverlay for MangoHud, vkBasalt, and vkSumi.

### Modified Capabilities

## Impact

- `overlayunit.lfm`: Adds `loadconfigMenuItem` to `popsaveMenu`.
- `overlayunit.pas`: Implements `loadconfigMenuItemClick` and controls `loadconfigMenuItem` visibility in `popupBitBtnClick`.
