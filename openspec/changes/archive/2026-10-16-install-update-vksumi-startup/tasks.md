# Tasks

## 1. Startup Library Audit & Version Tracking

- [x] 1.1 Add vkSumi (`libVkLayer_vksumi.so` and `vksumi.json`) verification to `HasMissingMandatoryLibraries` in `optiscaler_update.pas` and verify clean build.
- [x] 1.2 Implement `ReadLocalVkSumiVersion: string` in `optiscaler_update.pas` reading from `goverlay.vars` and fallback `version.txt`.
- [x] 1.3 Implement `IsVkSumiUpdateAvailable: Boolean` in `optiscaler_update.pas` querying `https://api.github.com/repos/reakjra/vkSumi/releases/latest` with curl timeouts (2s connect, 4s max) and comparing against local version.

## 2. Startup Download Trigger & Installation Enhancements

- [x] 2.1 Integrate `IsVkSumiUpdateAvailable` into `StartupDownloadsAsync` in `overlayunit.pas` (`NeedsDownload := HasMissingMandatoryLibraries or IsOptiPatcherUpdateAvailable or IsVkSumiUpdateAvailable;`).
- [x] 2.2 Update `CheckAndInstallVkSumi` in `optiscaler_update.pas` to check if an update is available or forced, update the static fallback URL to `v0.1.0`, and record the installed version tag into `goverlay.vars` and `version.txt`.

## 3. Verification & Testing

- [x] 3.1 Add unit and GUI tests in `tests/gui/gui_test_cases.pas` verifying that missing vkSumi is reported by `HasMissingMandatoryLibraries` and verifying `IsVkSumiUpdateAvailable`.
- [x] 3.2 Run full project build (`make goverlay`) and execute all automated test suites (`make test-logic` and `make test-gui`) verifying zero errors and zero failures.
