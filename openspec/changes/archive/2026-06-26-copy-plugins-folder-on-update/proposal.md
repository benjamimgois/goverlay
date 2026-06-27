## Why

Manual update does not copy `plugins/` directory (containing `OptiPatcher.asi`) from pristine `.bgmod_original` to global `bgmod`.

## What Changes

- GOverlay copy logic inside `UpdateButtonClick` must copy the `plugins/` folder if it exists.

## Capabilities

### New Capabilities

### Modified Capabilities

- `bgmod-update-optiscaler`: GOverlay must sync the `plugins/` folder to the global folder during update.

## Impact

- `optiscaler_update.pas` (`UpdateButtonClick`).
