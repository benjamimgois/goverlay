## Why

Automated OptiScaler packaging does not contain `goverlay.vars`. Without it, GOverlay UI shows blank status and cannot check updates.

## What Changes

- GOverlay automatically generates `goverlay.vars` with `OptiScalerVersion` during the update/install process.

## Capabilities

### New Capabilities

### Modified Capabilities

- `bgmod-update-optiscaler`: GOverlay must generate `goverlay.vars` in `.bgmod_original` and global folder if missing during update, and record the installed version tag.

## Impact

- `optiscaler_update.pas` (specifically `UpdateButtonClick` where installation files are synced and version labels updated).
