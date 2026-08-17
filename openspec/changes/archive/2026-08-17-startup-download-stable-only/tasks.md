# Tasks: Download Only Stable OptiScaler and DLSS Enabler on Startup

## 1. Startup Downloads Logic Update

- [x] 1.1 In `overlayunit.pas`, update `StartupDownloadsAsync` to only check for existence of stable OptiScaler and DLSS Enabler DLLs
- [x] 1.2 In `overlayunit.pas`, update `TStartupDownloadThread.Execute` to only call `CheckAndInstallOptiScaler(..., True)` and `CheckAndInstallDlssEnabler(True, ...)`
- [x] 1.3 In `optiscaler_update.pas`, update progress percentages in `CheckAndInstallOptiScaler` (0% to 50%) and `CheckAndInstallDlssEnabler` (50% to 95%) for stable channel

## 2. In-App Edge On-Demand Installation UI

- [x] 2.1 In `optiscaler_update.pas` `TOptiUpdateThread.SyncUpdateUI`, ensure that when `CurrentVersion` is empty/missing and a remote tag is found, `HasUpdates` is set to True to display `FUpdateBtn` ("Update" / "Install")

## 3. Testing and Validation

- [x] 3.1 Run unit and GUI tests (`make test` and `make test-logic`) and verify clean release build
