## Why

When DLSS Enabler is installed or updated, `DownloadAndExtractDlssEnabler` in `optiscaler_update.pas` writes `dlssenablerversion=4.8.10.11` into `goverlay.vars`. However, `SyncUpdateUI` compares `FLatestOptiTag` (the remote release tag from GitHub, e.g. `v0.10.0-pre1_7233fc0c`) against `CurrentVersion` (`4.8.10.11`). Because `"4.8.10.11" != "v0.10.0-pre1_7233fc0c"`, GOverlay falsely alerts that an update is available every time the application is restarted, even immediately after a successful update.

## What Changes

- **Persist Release Tag**: Save `dlssenablertag=<TagName>` (e.g. `v0.10.0-pre1_7233fc0c`) to `goverlay.vars` when extracting DLSS Enabler in `DownloadAndExtractDlssEnabler`.
- **Match Release Tag in Update Check**: In `SyncUpdateUI` (when `IsDlssEnablerActive` is `True`), read `dlssenablertag` (or fallback `optiScalerVersion`) as `CurrentVersion` instead of reading numeric `dlssenablerversion`.
- **Prefix Comparison & Fallback**: Implement comparison checks (`Pos` and `SameText`) so existing installations without `dlssenablertag` recognize base version equality and suppress false update banners.

## Capabilities

### New Capabilities

### Modified Capabilities
- `dlss-enabler-rolling-update`: Fixes false update notifications by persisting and matching the full GitHub release tag.

## Impact

- `optiscaler_update.pas`: Updates `DownloadAndExtractDlssEnabler` to write `dlssenablertag` and `SyncUpdateUI` to compare against `dlssenablertag`/`optiScalerVersion`.
- `tests/gui/gui_test_cases.pas`: Adds GUI unit tests for DLSS Enabler tag persistence and update status suppression.
