## 1. Release Asset Filtering

- [x] 1.1 Update `GetMakoLatestRemoteVersion` in `optiscaler_update.pas` to strictly match `-linux.tar.xz` and exclude any asset containing `flatpak`, verifying the parsed download URL matches the native Linux archive.

## 2. In-Memory Update State Persistence

- [x] 2.1 Add `FMakoRemoteVer: string` and `FMakoUpdateAvailable: Boolean` fields and accessors to `TLosslessScalingTabHelper` in `lossless_scaling_tab.pas`.
- [x] 2.2 Update `TMakoCheckUpdateThread.SyncResult` to store `FMakoRemoteVer` and `FMakoUpdateAvailable := True` when a newer version is detected.

## 3. UI Preservation on Lossless Scaling Tab

- [x] 3.1 Modify `UpdateEngineStatus` in `lossless_scaling_tab.pas` so it does not overwrite the status label or hide `FLsInstallBtn` when `FMakoUpdateAvailable` is true.
- [x] 3.2 Modify `UpdateStatusCard` in `lossless_scaling_tab.pas` to display `CleanLocal → FMakoRemoteVer` in accent color (`$0044AAFF`) on `FLsStatusMakoVer` when `FMakoUpdateAvailable` is true.

## 4. Home Tab Status Synchronization

- [x] 4.1 Implement `RefreshHomeMakoStatus` in `home_tab.pas` (or `overlayunit.pas`) to update `FHomeModVerLbls[5]` with `CleanLocal → FMakoRemoteVer` in accent styling.
- [x] 4.2 Call `RefreshHomeMakoStatus` from `TMakoCheckUpdateThread.SyncResult` when an update is found, matching OptiScaler behavior.

## 5. Verification and Build

- [x] 5.1 Compile GOverlay with `lazbuild` to verify clean build without syntax errors or regressions.
- [x] 5.2 Verify that MAKO 3.1.0 update notification appears on Home tab and Lossless Scaling tab without disappearing when switching tabs.
