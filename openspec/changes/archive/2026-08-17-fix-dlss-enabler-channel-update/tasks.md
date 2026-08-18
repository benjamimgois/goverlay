## 1. DLSS Enabler Update Logic & Version Comparison

- [x] 1.1 In `optiscaler_update.pas` (`TOptiUpdateThread.SyncUpdateUI`), normalize DLSS Enabler versions and compare using `CompareVersions(NormLatest, NormCurrent) > 0` instead of string inequality.
- [x] 1.2 In `optiscaler_update.pas` (`GetDlssEnablerLatestTag`), remove hardcoded fallback version strings (`4.8.13.6` and `4.8.12`) on discovery failure.
- [x] 1.3 Ensure channel-specific `goverlay.vars` is checked and verified in `SyncUpdateUI` according to `FIsStableChannel`.

## 2. Testing and Validation

- [x] 2.1 Add automated GUI test in `tests/gui/gui_test_cases.pas` verifying that DLSS Enabler on Bleeding-edge with installed `4.9.0.6` does not offer an update to older `4.8.13.6` and only offers updates for higher versions (`4.9.0.7+`).
- [x] 2.2 Verify that all logic and GUI test suites pass cleanly.
