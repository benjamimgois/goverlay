## Why

User-configured OptiScaler settings are frequently lost. Specifically, `force_reflex` in `fakenvapi.ini` is reset to 0 (Follow game setting) on every GOverlay startup/update because the file is unconditionally overwritten with a template, and "Spoof DLSS" is reset to unchecked due to a case-sensitive, space-sensitive INI parser that fails to find existing keys.

## What Changes

- **Preserve User `fakenvapi.ini`**: Update startup and update sync scripts to only copy `fakenvapi.ini` if it does not already exist in the target directory, preventing user modifications from being overwritten.
- **Robust INI Key Resolution**: Modify GOverlay's `TConfigFile` parser to resolve keys in a case-insensitive and whitespace-tolerant manner. This ensures user configurations such as `Dxgi=auto` in `OptiScaler.ini` are correctly loaded even if formatted differently by the user or OptiScaler.

## Capabilities

### New Capabilities

### Modified Capabilities

## Impact

- `bgmod_resources.pas`: Sychronization commands in `InitializeGlobalConfigDirectory` will use conditional checks for `fakenvapi.ini`.
- `optiscaler_update.pas`: Sychronization commands in `SyncPristineAssetsTo` will use conditional checks for `fakenvapi.ini`.
- `configfile.pas`: `TConfigFile` helper methods `FindLineIndex` and `FindLineIndexInSection` will utilize normalized, case-insensitive, space-stripped comparisons.
