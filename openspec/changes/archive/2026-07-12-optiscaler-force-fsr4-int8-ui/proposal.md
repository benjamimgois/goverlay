## Why

When utilizing the bleeding-edge channel of OptiScaler, the "Emulate FP8" configuration is not applicable. Instead, the "Force FSR4-i8" flag (persisted in OptiScaler.ini as Fsr4ForceEnableInt8) needs to be configured and toggled easily by the user. Providing a dynamic checkbox that replaces "Emulate FP8" when bleeding-edge is selected streamlines the user interface, ensures correct configuration options are displayed for the active channel, and enables FSR4 INT8 force precision settings.

## What Changes

- Hide the "Emulate FP8" checkbox and show the new "Force FSR4-i8" checkbox in its place when using the bleeding-edge channel of OptiScaler.
- Hide the "Force FSR4-i8" checkbox and restore the "Emulate FP8" checkbox when using the stable channel of OptiScaler.
- Set the default value of "Force FSR4-i8" to `true` (checked by default).
- Search and write the value of "Force FSR4-i8" to the line `Fsr4ForceEnableInt8=` under `OptiScaler.ini` (value `true` when checked, `false` when unchecked). If the line does not exist, append it.
- Correctly parse and load the `Fsr4ForceEnableInt8` value from `OptiScaler.ini` to populate the checkbox state, defaulting to `true` if not found.

## Capabilities

### New Capabilities
- `optiscaler-force-fsr4-int8-ui`: Dynamic display and persistence of the "Force FSR4-i8" setting replacing "Emulate FP8" on the OptiScaler bleeding-edge update channel.

### Modified Capabilities
<!-- None -->

## Impact

- `overlayunit.pas`: Add field for `forceFsr4Int8CheckBox`, add dynamic visibility logic inside `fsrversionComboBoxChange`.
- `optiscaler_tab.pas`: Instantiate the new checkbox, handle loading/saving of its state.
- `overlay_config.pas`: Update `TOptiScalerSettings` structure, add load/save parser logic in `LoadOptiScalerConfig` and `SaveOptiScalerConfigCore` to interact with `OptiScaler.ini`.
