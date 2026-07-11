## 1. Conditional fakenvapi.ini copy

- [x] 1.1 In `bgmod_resources.pas`, modify `InitializeGlobalConfigDirectory` to only copy `fakenvapi.ini` if it does not already exist in the target global config directory.
- [x] 1.2 In `optiscaler_update.pas`, modify `SyncPristineAssetsTo` to only copy `fakenvapi.ini` if it does not already exist in the target game config directory.

## 2. Robust TConfigFile Key Resolution

- [x] 2.1 In `configfile.pas`, implement the private helper function `CleanKeyLine` to strip whitespaces/tabs and convert characters to lowercase.
- [x] 2.2 In `configfile.pas`, refactor `FindLineIndex` to match keys case-insensitively and space-insensitively using `CleanKeyLine`.
- [x] 2.3 In `configfile.pas`, refactor `FindLineIndexInSection` to match keys case-insensitively and space-insensitively using `CleanKeyLine`.

## 3. Verification

- [x] 3.1 Verify building the project compiles successfully.
- [x] 3.2 Verify the `fakenvapi.ini` conditional copy logic on GOverlay startup and manual updates.
- [x] 3.3 Verify that saving and re-loading `OptiScaler.ini` correctly persists and parses the `Dxgi` key even if it contains spaces or lowercase characters.
