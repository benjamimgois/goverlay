## Why

When loading the MangoHud configuration, the UI controls (checkboxes, inputs, radio buttons, color buttons, trackbars) are not reset to their default values before parsing the configuration file. As a result, options that are absent from the loaded file retain the values from the previously loaded configuration. This causes configuration state leakage (bleeding) between game configurations, and between game and global configurations.

## What Changes

- Add a method to reset all MangoHud UI controls on the main form to their default/factory values.
- Invoke this redefinition method inside `LoadMangoHudConfig` immediately before parsing the configuration file.
- This ensures that only options present in the loaded configuration file are active in the UI, and all other options are correctly reset to their default values.

## Capabilities

### New Capabilities
- `mangohud-ui-reset-on-load`: Automatically resets the MangoHud user interface controls to their default state before loading a new configuration, preventing settings leakage.

### Modified Capabilities

## Impact

- `mangohud_ui.pas`: Add the reset method `ResetMangoHudControls` and call it at the start of `LoadMangoHudConfig` (right after checking that the config file exists).
