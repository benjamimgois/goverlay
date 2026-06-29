## Why

Many users do not read release notes published on GitHub releases. Displaying a clean popup modal on the very first launch of a new GOverlay version helps highlight major features and improvements. Once dismissed by the user, the popup will not be shown again for that version.

## What Changes

- Check `ChangelogSeenVersion` in `~/.config/goverlay/goverlay.ini` upon application startup.
- If `ChangelogSeenVersion` does not match the current `GVERSION`, fetch the release body for `v<GVERSION>` (or current tag/release) from the GitHub REST API (`https://api.github.com/repos/benjamimgois/goverlay/releases`).
- Display a modern modal dialog (Changelog Form / Popup) showing the release notes text.
- Save `ChangelogSeenVersion = GVERSION` to `goverlay.ini` when the popup is closed.

## Capabilities

### New Capabilities
- `release-changelog-popup`: Displays a release notes popup on the first launch of a new version using GitHub release notes.

### Modified Capabilities
<!-- None -->

## Impact

- `goverlay_system.pas`: Added helper function to fetch release body for current version from GitHub API.
- `changelogunit.pas` / `changelogunit.lfm` (NEW): Form for rendering the changelog popup.
- `overlayunit.pas`: Integrated first-launch check in `FormCreate` / startup routines.
