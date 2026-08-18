# Tasks: Defer Changelog Popup Until Main Window Is Visible

## 1. Startup Flow Coordination
- [x] 1.1 In `overlayunit.pas` (`FormShow`), remove immediate `Application.QueueAsyncCall(@ShowChangelogAsync, 0)` and only call it directly if startup downloads are bypassed (`TestMode` or `not IsBGModInitialized`).
- [x] 1.2 In `overlayunit.pas` (`StartupDownloadsAsync`), trigger `Application.QueueAsyncCall(@ShowChangelogAsync, 0)` when no downloads are needed, as well as after downloads complete (`HideBootSplash` / `Self.Show`).

## 2. Defensive Presentation Guard
- [x] 2.1 In `overlayunit.pas` (`TChangelogFetchThread.DoShowChangelog`), guard against showing the popup if `not goverlayform.Visible` or `Assigned(goverlayform.FSplashForm)`, re-queueing via `QueueAsyncCall` instead.

## 3. Verification & Testing
- [x] 3.1 Verify compilation with `lazbuild --build-mode=Release goverlay.lpi`.
- [x] 3.2 Run test suites (`make test-logic`, `make test-gui`) to ensure no regressions in startup and changelog behavior.
