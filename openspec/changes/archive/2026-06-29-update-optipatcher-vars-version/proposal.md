## Why

When OptiScaler is updated or installed by GOverlay, `goverlay.vars` is written/updated to track versions of all installed components (`OptiScalerVersion`, `FakeNvapiVersion`, `xessversion`, `fsrversion`, `dlssversion`, etc.). However, the `optipatcher` key in `goverlay.vars` is not currently updated during OptiScaler installation. Because GOverlay bundles the latest rolling release of OptiPatcher with each OptiScaler build, writing `optipatcher=rolling-yyyy.MM.dd` (using the current local installation date) ensures `goverlay.vars` correctly reflects the installed OptiPatcher version.

## What Changes

- Update `UpdateButtonClick` and `EnsureOptiScalerInstalled` in `optiscaler_update.pas` when writing `goverlay.vars` to write or update the `optipatcher` key.
- Format the value as `rolling-yyyy.MM.dd` (e.g., `rolling-2026.06.29`) based on current system date at installation time.
- Write this value to both the active config directory (`goverlay.vars`) and the pristine `.bgmod_original/goverlay.vars` directory.

## Capabilities

### New Capabilities
- `update-optipatcher-vars-version`: Automatically updates the `optipatcher=rolling-yyyy.MM.dd` version key in `goverlay.vars` whenever OptiScaler is installed or updated.

### Modified Capabilities
<!-- None -->

## Impact

- `optiscaler_update.pas`: Adds `optipatcher=rolling-yyyy.MM.dd` key updating logic in `UpdateButtonClick` and `EnsureOptiScalerInstalled`.
