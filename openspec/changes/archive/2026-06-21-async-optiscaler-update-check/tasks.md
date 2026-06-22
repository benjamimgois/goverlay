## 1. Implement Thread-Safe Update Check

- [x] 1.1 Modify tag fetching functions in optiscaler_update.pas to support silent mode (no LCL dialogs in background thread)
- [x] 1.2 Implement TOptiUpdateThread class in optiscaler_update.pas to retrieve tags in a background thread
- [x] 1.3 Add thread lifecycle management and callback synchronization in optiscaler_update.pas

## 2. UI Hookup and Verification

- [x] 2.1 Update TOptiscalerTab.CheckForUpdatesOnClick to show checking status on FOptiLabel2 and disable FCheckupdBtn, then spawn the background thread
- [x] 2.2 Verify that the background thread runs without blocking GOverlay's startup and updates the tab UI on completion
- [x] 2.3 Verify manual update check and channel changing also trigger the async update check correctly
