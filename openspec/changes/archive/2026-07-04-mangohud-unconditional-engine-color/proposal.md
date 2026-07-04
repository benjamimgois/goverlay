## Why

Currently, GOverlay only writes the `engine_color` setting to the MangoHUD configuration file when `engine_version` is enabled. If a user applies color themes like "Simple White" or "Old afterburner", the `engine_color` is configured on the color buttons but omitted from the config file if `engine_version` is unchecked, causing inconsistencies if the engine display is enabled through other means (like global environment variables or custom overrides).

## What Changes

- Make the writing of `engine_color` to the MangoHUD config file unconditional, similar to general settings like `text_color` and `background_color`.
- Ensure that clicking on color themes ("Simple White", "Old afterburner", "Goverlay", and "MangoHud Stock") correctly propagates and saves the updated `engine_color` to the `MangoHud.conf` file.

## Capabilities

### New Capabilities
- `mangohud-engine-color-unconditional`: Always write `engine_color` setting to the MangoHUD configuration.

### Modified Capabilities
<!-- None -->

## Impact

- `overlay_config.pas`: Modify logic for writing the engine configuration section.
- `overlayunit.pas`: None (theme button click logic already updates the button color).
