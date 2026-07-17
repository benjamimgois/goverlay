## Why

When returning from a game-specific configuration to the global configuration mode, the MangoHud configuration tab in GOverlay fails to reload the global `MangoHud.conf` settings. Consequently, the user interface continues to display the settings of the previously selected game. If the user makes any edits or clicks "Save" while in this state, the game's settings are incorrectly saved to the global config, overwriting the user's global settings.

## What Changes

- Update the navigation click handler for the MangoHud tab sheet to reload the MangoHud configuration unconditionally when navigating to the tab.
- This ensures that the user interface always synchronizes with the active context (global or game-specific) when entering the MangoHud tab.

## Capabilities

### New Capabilities

- `mangohud-global-config-sync`: Ensures that entering the MangoHud tab always synchronizes the UI controls with the active configuration context (global or game-specific), preventing configuration state leakage.

### Modified Capabilities

## Impact

- `overlayunit.pas`: The `mangohudLabelClick` method will be modified to remove the condition that prevents config loading in global mode.
