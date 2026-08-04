# Design: Fix DLSS Enabler False Update Notification

## Context

When DLSS Enabler is active, `GetDlssEnablerLatestTag` queries `https://api.github.com/repos/bygalacos/OptiScalerBuilder/releases/latest` and returns the release `tag_name` (e.g., `v0.10.0-pre1_7233fc0c`).
In `DownloadAndExtractDlssEnabler`, GOverlay writes `dlssenablerversion=4.8.10.11` to `goverlay.vars`.
During update checks in `SyncUpdateUI`, `CurrentVersion` was assigned `VarsList.Values['dlssenablerversion']` (`4.8.10.11`) and compared directly to `FLatestOptiTag` (`v0.10.0-pre1_7233fc0c`). Since `"4.8.10.11" <> "v0.10.0-pre1_7233fc0c"` is always true, GOverlay displays a false update notification on every startup.

## Design Decisions

### 1. Store Release Tag in `goverlay.vars`
In `DownloadAndExtractDlssEnabler` (`optiscaler_update.pas`):
```pascal
VarsList.Add('dlssenablerversion=' + DlssEnablerVerStr);
VarsList.Add('optiScalerVersion=' + OptiScalerVerStr);
VarsList.Add('dlssenablertag=' + TagName);
VarsList.Add('upscalertype=1');
```

### 2. Update Version Matching in `SyncUpdateUI`
In `SyncUpdateUI` (`optiscaler_update.pas`):
```pascal
if IsDlssEnablerActive then
begin
  CurrentVersion := VarsList.Values['dlssenablertag'];
  if CurrentVersion = '' then
    CurrentVersion := VarsList.Values['optiScalerVersion'];
  if CurrentVersion = '' then
    CurrentVersion := VarsList.Values['dlssenablerversion'];
  ...
  HasUpdate := (FLatestOptiTag <> '') and (CurrentVersion <> '') and (CurrentVersion <> '—') and
               (not SameText(CurrentVersion, FLatestOptiTag)) and
               (Pos(CurrentVersion, FLatestOptiTag) <> 1);
end;
```

## Risk Analysis

- **Backward Compatibility**: Existing `goverlay.vars` without `dlssenablertag` fall back to `optiScalerVersion` (e.g. `v0.10.0-pre1`). The prefix check `Pos(CurrentVersion, FLatestOptiTag) <> 1` ensures `v0.10.0-pre1` matches `v0.10.0-pre1_7233fc0c` without triggering false update alerts.

## Migration / Compatibility

No manual file changes required. Future updates and existing installations automatically resolve release tag matching cleanly.
