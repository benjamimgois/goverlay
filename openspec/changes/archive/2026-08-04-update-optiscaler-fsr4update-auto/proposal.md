## Why

In OptiScaler configuration files (`OptiScaler.ini`), setting `Fsr4Update=auto` is the preferred mode over hardcoding `Fsr4Update=true` when selecting the Latest FSR version. Currently, GOverlay writes `Fsr4Update=true` when saving OptiScaler settings. Updating this default value to `auto` ensures proper auto-update handling in OptiScaler while maintaining compatibility when reading existing configuration files.

## What Changes

- Modify `overlay_config.pas` (`SaveOptiScalerConfig`) so that `Fsr4UpdateValue` is assigned `'auto'` instead of `'true'` when saving OptiScaler settings.
- Modify `overlay_config.pas` (`LoadOptiScalerConfig`) so that `Fsr4Update` is recognized for both `'auto'` and `'true'` (enabling seamless migration of existing `.ini` files from `true` to `auto`).
- Update UI tooltip (`Hint`) in `overlayunit.lfm` for `fsrversionComboBox` to mention `Fsr4Update=auto` instead of `Fsr4Update=true`.
- Update automated GUI test in `tests/gui/gui_test_cases.pas` to assert `Fsr4Update=auto` upon saving OptiScaler configuration.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `optiscaler-persistence`: Update `Fsr4Update` key persistence value from `true` to `auto` when Latest FSR version is active.

## Impact

- `overlay_config.pas`: Save and load methods for OptiScaler configuration.
- `overlayunit.lfm`: Tooltip string for FSR version dropdown.
- `tests/gui/gui_test_cases.pas`: Automated GUI test assertion for FSR version persistence.
