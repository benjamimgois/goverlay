# Tasks: Notify and Allow User Update for DLSS Enabler Rolling Releases

- [x] 1. Implement Tag-Based Comparison & Notification (`optiscaler_update.pas`)
  - [x] 1.1 Store full release `tag_name` in `goverlay.vars` under `dlssenablerversion`.
  - [x] 1.2 Update `TOptiUpdateThread` and update check routines to perform full tag comparison for DLSS Enabler.
  - [x] 1.3 Show update notification toast, update status dot to yellow, and reveal the Update button when a new tag is detected.

- [x] 2. User-Triggered Installation & UI Refresh (`optiscaler_update.pas` & `overlayunit.pas`)
  - [x] 2.1 Update `CheckAndInstallDlssEnabler(True)` to extract and write full release `tag_name` to `goverlay.vars`.
  - [x] 2.2 Instant UI refresh of status labels (`FDlssEnablerLabel` & `FOsStatVerLbls`) and status dot to green upon installation.

- [x] 3. Verification & Testing
  - [x] 3.1 Verify compilation with `lazbuild goverlay.lpi --bm=Release --widgetset=qt6`.
  - [x] 3.2 Test update detection, notification, and installation flow for DLSS Enabler.
