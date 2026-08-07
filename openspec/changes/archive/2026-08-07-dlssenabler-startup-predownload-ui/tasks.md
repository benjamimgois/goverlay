# Implementation Tasks: DLSS Enabler Bleeding-Edge Startup Pre-download & Progress UI

- [x] 1. Update Startup Asset Download Logic
  - [x] 1.1 In `overlayunit.pas`, invoke `CheckAndInstallDlssEnabler(False, False)` during startup asset initialization.
  - [x] 1.2 In `optiscaler_update.pas`, invoke `CheckAndInstallDlssEnabler(False, False)` inside `CheckAndInstallOptiScaler`.

- [x] 2. Implement Progress Bar & Status Label UI for Startup Downloads
  - [x] 2.1 In `overlayunit.pas`, show `updateProgressBar` and set `updatestatusLabel.Caption := 'Downloading files...'` during startup downloads.
  - [x] 2.2 Hide `updateProgressBar` and `updatestatusLabel` when startup downloads finish.

- [x] 3. Build & Verification
  - [x] 3.1 Rebuild `goverlay` using `lazbuild -B goverlay.lpi`.
  - [x] 3.2 Verify that both stable and bleeding-edge DLSS Enabler assets are downloaded at startup with progress bar UI feedback.
