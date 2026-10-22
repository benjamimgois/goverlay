## Why

Currently, GOverlay checks for available `lsfg-vk` updates by scraping `https://builds.lsfg-vk.dev/`. The parser accepts both `Latest release (` and `Latest git version (`. Because upstream autobuilds place git commit builds (`Latest git version`) at the top of the table before stable releases, any minor commit pushed to the `lsfg-vk` repository is detected as a new version (e.g., `2.0.0.r1.g0e7a389`), causing GOverlay to display an update notification and prompt the user to install an unstable development build over their stable `2.0.0` installation.

Restricting update checks strictly to official stable releases ensures users only receive notifications and updates for vetted, stable versions.

## What Changes

- Update `GetLsfgVkLatestRemoteVersion` in `optiscaler_update.pas` to match exclusively against official stable releases (`Latest release (`), ignoring git autobuilds (`Latest git version`) and pre-releases (`Latest release candidate`).
- Ensure the remote version and download URL resolved for update notifications and installations point only to stable release tarballs.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `lsfg-vk-auto-install`: Restrict remote version detection and update notifications for `lsfg-vk` to official stable releases only, preventing git commit autobuilds from triggering update prompts.

## Impact

- `optiscaler_update.pas`: `GetLsfgVkLatestRemoteVersion` remote scraping logic.
- `lossless_scaling_tab.pas`: Software Status card and update notification display (will no longer prompt for git builds when stable 2.0.0 is installed).
- Automated tests in `tests/gui/gui_test_cases.pas` verifying update status behavior.
