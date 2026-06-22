## Why

GOverlay currently performs the OptiScaler update check on startup by calling the GitHub API synchronously. Depending on network conditions and API responsiveness, this blocking network call can cause startup delays ranging from 2 to 10 seconds, freezing the GUI. Making the update check asynchronous will keep the UI responsive immediately upon launch.

## What Changes

- Make the OptiScaler and fgmod update checks asynchronous by running them in a background thread.
- Show a temporary, friendly notification message like "Searching for updates..." next to the version label on the OptiScaler tab of GOverlay during the update check.
- Keep the check button disabled while the background check is in progress to prevent duplicate requests.
- Refresh the home tab status cards and status indicators immediately once the background update check completes.

## Capabilities

### New Capabilities
- `goverlay-async-update-check`: Perform the OptiScaler and fgmod update checks asynchronously in a background thread on startup and manual refresh, displaying a status message on the OptiScaler tab without blocking UI rendering.

### Modified Capabilities

## Impact

- `optiscaler_update.pas`: Modify TOptiscalerTab to initiate update checks using a background thread and handle asynchronous completion UI updates.
- `overlayunit.pas`: Modify FormCreate to start the update check asynchronously on startup, and adjust button/combobox action callbacks.
