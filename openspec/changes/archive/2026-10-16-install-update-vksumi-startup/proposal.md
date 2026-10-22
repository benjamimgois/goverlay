# Proposal: Install and Update vkSumi on Startup

## Why

Goverlay recently gained UI controls for vkSumi (split-screen compare mode and color blindness daltonization). However, vkSumi is not currently audited in `HasMissingMandatoryLibraries`, which prevents Goverlay from detecting when the Vulkan layer is missing on a clean install and downloading it via the boot splash. Furthermore, vkSumi has no automatic update mechanism: once downloaded, Goverlay never checks GitHub for new releases or updates the installed binary. Adding vkSumi to startup verification and implementing version tracking and update monitoring ensures users always receive and run the latest upstream version seamlessly.

## What Changes

- Add vkSumi (`libVkLayer_vksumi.so` / `vksumi.json`) to the mandatory startup integrity check in `HasMissingMandatoryLibraries` (`optiscaler_update.pas`).
- Introduce `IsVkSumiUpdateAvailable: Boolean` and `ReadLocalVkSumiVersion: string` in `optiscaler_update.pas` to query the latest release tag from `https://api.github.com/repos/reakjra/vkSumi/releases/latest` with a fast timeout and compare against the locally recorded version.
- Persist the installed vkSumi release tag (e.g., `vksumi=v0.1.0`) in `goverlay.vars` upon successful download/installation in `CheckAndInstallVkSumi`.
- Hook `IsVkSumiUpdateAvailable` into `StartupDownloadsAsync` in `overlayunit.pas` (`NeedsDownload := ... or IsVkSumiUpdateAvailable;`), triggering the download splash when an update is detected.
- Update `CheckAndInstallVkSumi` to detect when an update is available (or `AForce = True`) and replace the existing shared library and manifest with the new version.
- Update the hardcoded static download fallback URL in `CheckAndInstallVkSumi` from legacy `v0.0.7` to `v0.1.0`.

## Capabilities

### Modified Capabilities
- `vksumi-auto-install`: Extend requirements to include release version tracking, update availability checks against the upstream GitHub API, and automated upgrading of existing installations.
- `startup-libraries-verification`: Add the vkSumi Vulkan layer to the mandatory startup libraries audit list in `HasMissingMandatoryLibraries` and trigger startup downloads when missing or outdated.

## Impact

- `optiscaler_update.pas`: Updates `HasMissingMandatoryLibraries`, adds `ReadLocalVkSumiVersion` and `IsVkSumiUpdateAvailable`, updates `CheckAndInstallVkSumi` to persist version in `goverlay.vars` and refresh fallbacks.
- `overlayunit.pas`: Updates `StartupDownloadsAsync` to evaluate `IsVkSumiUpdateAvailable` when determining `NeedsDownload`.
- `tests/gui/gui_test_cases.pas`: Adds unit/GUI tests covering missing vkSumi detection and update checks.
