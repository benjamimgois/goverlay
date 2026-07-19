## Why

Currently, GOverlay defines the fallback version of FSR Stable as "4.1" in its code. However, the latest stable release of OptiScaler (v0.9.4) ships with FSR version 4.1.1. Updating the hardcoded fallback values in GOverlay ensures that the application defaults to the correct version (4.1.1) in case of network failures or when using default configuration templates.

## What Changes

- Update the fallback value of FSR stable version from `4.1` to `4.1.1` in `optiscaler_update.pas`.

## Capabilities

### New Capabilities

<!-- None -->

### Modified Capabilities

- `bgmod-update-optiscaler`: Update FSR stable version fallback value to `4.1.1` when parsing versions during installation.

## Impact

- `optiscaler_update.pas`: Modify the `FsrStableVal := '4.1';` initialization statements to `FsrStableVal := '4.1.1';`.
