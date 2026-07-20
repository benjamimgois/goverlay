## Why

GOverlay fails to detect updates for the OptiScaler stable channel because the remote version string has a `stable-` prefix (e.g. `stable-0.9.4`), while the local version file does not, resulting in an incorrect version comparison (comparing "stable" vs "0"). This proposal ensures that both `stable.` and `edge.` prefixes are stripped before comparison so that stable channel updates are correctly detected and installed.

## What Changes

- Modify OptiScaler update thread UI synchronization logic to strip the `stable.` prefix from both remote and local versions during normalization.
- Enable correct version detection and updates for OptiScaler on the stable channel when using Flatpak or any other installation.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `bgmod-update-optiscaler`: Update version detection/comparison requirements to correctly strip both `edge.` and `stable.` version prefixes.

## Impact

- `optiscaler_update.pas`: Specifically, the `TOptiUpdateThread.SyncUpdateUI` version normalization logic.
