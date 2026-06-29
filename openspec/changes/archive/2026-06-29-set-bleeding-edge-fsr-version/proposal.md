## Why

When installing or updating OptiScaler on the bleeding-edge channel, the FSR version in `goverlay.vars` should be explicitly set to `"4.1.1"`. Currently, installing/updating OptiScaler does not explicitly set `fsrversion=4.1.1` in `goverlay.vars` for bleeding-edge builds, causing missing or inconsistent FSR version reporting.

## What Changes

- Update `UpdateButtonClick` and `EnsureOptiScalerInstalled` in `optiscaler_update.pas` to write `fsrversion=4.1.1` to `goverlay.vars` when installing or updating on the bleeding-edge channel (`not IsStableChannel`).
- Ensure both active and `.bgmod_original` copies of `goverlay.vars` receive this update.

## Capabilities

### New Capabilities
- `set-bleeding-edge-fsr-version`: Writes `fsrversion=4.1.1` to `goverlay.vars` when OptiScaler is installed or updated on the bleeding-edge channel.

### Modified Capabilities
<!-- None -->

## Impact

- `optiscaler_update.pas`: Adds `fsrversion=4.1.1` key writing logic during bleeding-edge OptiScaler updates/installations.
