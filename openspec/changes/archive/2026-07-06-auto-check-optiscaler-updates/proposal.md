## Why

Currently, OptiScaler update checks are run on application startup, manual clicks, and automatically upon navigating to the OptiScaler tab page. However, the update checking trigger in `CheckForUpdatesOnClick` unconditionally overwrites the active configuration path (`FFGModPath`) with the global template path (`GetOptiScalerInstallPath`). This clobbers the active game-specific or global profile's versions, causing incorrect comparison displays (e.g. showing stable template version instead of the game's installed bleeding-edge version).

## What Changes

- Automatically trigger the OptiScaler update checking process whenever the user navigates to the OptiScaler tab in the UI.
- Correct the update checking logic in `CheckForUpdatesOnClick` to use a conditional fallback so that `FFGModPath` is only set to the global template folder if it is empty, preserving the active game or global profile's path.

## Capabilities

### New Capabilities

*(None)*

### Modified Capabilities

- `goverlay-async-update-check`: Update the requirements to execute update checks upon entering/opening the OptiScaler tab page, and to preserve active profile context during checking.

## Impact

- `overlayunit.pas`: The tab transition handler `optiscalerLabelClick` will trigger the update check.
- `optiscaler_update.pas`: `CheckForUpdatesOnClick` will use a conditional fallback for `FFGModPath` instead of overwriting it.
