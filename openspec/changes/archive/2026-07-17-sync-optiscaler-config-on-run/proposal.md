## Why

When the user changes the OptiScaler settings in the GOverlay GUI (such as changing the menu toggle key), the changes are saved to GOverlay's local configuration directory. However, when launching the game, the `bgmod` wrapper skips updating files in the game directory if the DLL versions have not changed, and even if they did, `PRESERVE_INI` prevents overwriting the existing `OptiScaler.ini` in the game directory. This prevents GUI adjustments from taking effect, leaving the game configuration stale.

## What Changes

- Update `bgmod.lpr` to synchronize `OptiScaler.ini` on game launch if the configuration directory's file is newer than the game directory's file (based on modification timestamp).
- Update `bgmod.lpr` to unconditionally sync `fakenvapi.ini` to the game directory on launch (if the config file exists), since `fakenvapi.ini` is only editable via GOverlay and not in-game.
- These updates must happen regardless of whether the main DLL files are deemed up-to-date.

## Capabilities

### New Capabilities

<!-- None -->

### Modified Capabilities

- `bgmod-update-optiscaler`: Add requirements for synchronization of `OptiScaler.ini` and `fakenvapi.ini` on game launch, resolving the version/preservation copy bypass logic.

## Impact

- `bgmod.lpr`: Launcher wrapper execution logic and copy/sync block.
