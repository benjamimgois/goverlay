## 1. Implementation

- [x] 1.1 Strip the `stable.` prefix from `NormLatest` and `NormCurrent` version strings in `optiscaler_update.pas` within `TOptiUpdateThread.SyncUpdateUI`.

## 2. Verification

- [x] 2.1 Rebuild GOverlay and verify that it compiles cleanly.
- [x] 2.2 Verify that stable channel updates are correctly detected by running GOverlay (if possible) or inspecting log output of version comparisons.
