## Why

When a new version of MAKO is released on GitHub (e.g., v3.1.0), GOverlay fails to notify users in the interface, unlike OptiScaler which seamlessly shows new version alerts (`3.0.0 → 3.1.0`). Investigation revealed four causes: (1) update detection status is unconditionally cleared whenever the user enters the Lossless Scaling tab, (2) detected remote version and update status are not persisted in memory, (3) the Home tab module list does not synchronize with MAKO update results, and (4) asset filtering in the remote release parser erroneously selects the Flatpak archive (`-flatpaks.tar.xz`) instead of the native Linux archive (`-linux.tar.xz`).

## What Changes

- **Persistent Remote Version & Update State**: Persist `FMakoRemoteVersion` and `FMakoUpdateAvailable` in session memory so that detected updates survive tab navigation and configuration reloading.
- **Preserve Update Notification on Tab Switch**: Prevent `UpdateEngineStatus` from obliterating detected update states, keeping the upgrade badge/caption (`3.0.0 → 3.1.0`) and the "Install update" button active until updated.
- **Software Status Card Update Display**: Display the upgrade notice (`3.0.0 → 3.1.0`) in accent color in the Lossless Scaling tab Software Status card, mirroring OptiScaler's status dot behavior.
- **Home Tab Module Status Synchronization**: Update the Home tab module indicator (`FHomeModVerLbls[5]`) to reflect available MAKO updates (`3.0.0 → 3.1.0`) when the background update thread detects a new release.
- **Strict Native Linux Archive Filtering**: Fix asset selection in `GetMakoLatestRemoteVersion` to match `-linux.tar.xz` specifically and exclude `-flatpaks.tar.xz` archives.

## Capabilities

### New Capabilities
None.

### Modified Capabilities
- `mako-engine-management`: Update version tracking, update notification persistence across tabs and Home tab, and restrict remote archive resolution to native Linux tarballs.

## Impact

- `lossless_scaling_tab.pas`: Update `TLosslessScalingTabHelper` fields, `UpdateEngineStatus`, `UpdateStatusCard`, and thread result synchronization.
- `optiscaler_update.pas`: Fix asset matching in `GetMakoLatestRemoteVersion` to prioritize native Linux tarball over Flatpak bundle.
- `home_tab.pas`: Update `UpdateHomeModulesStatus` and add synchronization callback/method for MAKO version status.
- `overlayunit.pas`: Hook MAKO update notification events to refresh Home tab and Lossless Scaling tab.
