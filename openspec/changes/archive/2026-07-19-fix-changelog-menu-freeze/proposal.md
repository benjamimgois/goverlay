## Why

When the user clicks the "What's New" option in the GOverlay settings menu, GOverlay triggers a synchronous `curl` fetch on the main GUI thread to get the latest release notes from GitHub. If the network connection is slow or missing, the entire GOverlay GUI freezes for several seconds (up to the curl timeout).

## What Changes

- Modify `whatsNewMenuItemClick` in `overlayunit.pas` to fetch the release notes and show the popup asynchronously in the background using `TChangelogFetchThread` instead of executing `GetReleaseNotes` synchronously on the main thread.

## Capabilities

### New Capabilities

### Modified Capabilities

- `release-changelog-popup`: Extend requirements to specify that manual triggering of the changelog popup (via the "What's New" menu item) must also run asynchronously and never block the main GUI loop.

## Impact

- **Affected Files**: `overlayunit.pas`
- **Dependencies/APIs**: Reuses `TChangelogFetchThread` to perform the background fetch and synchronize the popup presentation.
