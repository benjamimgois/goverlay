# Tasks: Fix DLSS Enabler False Update Notification

## 1. DLSS Enabler Tag Persistence & Matching

- [x] 1.1 In `optiscaler_update.pas` (`DownloadAndExtractDlssEnabler`), write `dlssenablertag=<TagName>` to `goverlay.vars`.
- [x] 1.2 In `optiscaler_update.pas` (`SyncUpdateUI`), read `dlssenablertag` (or `optiScalerVersion`) when `IsDlssEnablerActive` is True, and check tag prefix equality against `FLatestOptiTag`.

## 2. Automated GUI Unit Tests

- [x] 2.1 In `tests/gui/gui_test_cases.pas`, add unit test `TestDlssEnablerTagMatchingNoFalseUpdate` verifying `dlssenablertag` persistence and update notification suppression when local tag matches latest remote release tag.
