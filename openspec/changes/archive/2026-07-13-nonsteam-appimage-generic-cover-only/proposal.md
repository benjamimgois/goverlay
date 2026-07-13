## Why

To simplify the interface and prevent incorrect online cover search matches for standalone AppImage games (since many AppImage files have highly custom names that result in wrong matches), we will configure AppImage games to always use the local generic fallback cover art immediately instead of querying Steam Store or Bing.

## What Changes

- For detected AppImage files, generate and apply the local generic fallback cover art immediately.
- Prevent AppImage games from being queued for online cover downloads in the background cover thread.

## Capabilities

### New Capabilities
- `nonsteam-appimage-generic-cover-only`: Restrict AppImage game cards to use only the generic fallback cover.

### Modified Capabilities
<!-- None -->

## Impact

- `games_tab.pas` (`LoadNonSteamFolders`): For AppImage games with no cached cover, generate the fallback cover immediately and skip queueing them into the background cover downloader loop.
