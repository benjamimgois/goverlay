## 1. Configuration Fields and Parsers

- [x] 1.1 Add `ForceFsr4Int8Checked: Boolean;` to the `TOptiScalerSettings` record in `overlay_config.pas`
- [x] 1.2 In `overlay_config.pas` `LoadOptiScalerConfig`, default `Settings.ForceFsr4Int8Checked` to `True`
- [x] 1.3 In `overlay_config.pas` `LoadOptiScalerConfig`, load `Fsr4ForceEnableInt8` from `OptiScaler.ini` via `TConfigFile.GetValue` and set `Settings.ForceFsr4Int8Checked` accordingly
- [x] 1.4 In `overlay_config.pas` `SaveOptiScalerConfigCore`, write `Fsr4ForceEnableInt8` with `true`/`false` to `OptiScaler.ini` using `TConfigFile.SetValue`

## 2. User Interface Definition and Event Logic

- [x] 2.1 In `overlayunit.pas`, declare `forceFsr4Int8CheckBox: TCheckBox;` in the `Tgoverlayform` class declaration
- [x] 2.2 In `overlayunit.pas` `fsrversionComboBoxChange`, implement the dynamic visibility logic: if bleeding-edge (`optversionComboBox.ItemIndex = 1`), hide and uncheck `emufp8CheckBox`, and display `forceFsr4Int8CheckBox`. Otherwise, hide `forceFsr4Int8CheckBox` and restore `emufp8CheckBox` visibility

## 3. Dynamic Placement and Settings Sync

- [x] 3.1 In `optiscaler_tab.pas` `InitOptiScalerTab`, dynamically create `forceFsr4Int8CheckBox`, reparent it to `FOsOptiSec`, apply dark styling, set positioning anchors matching `emufp8CheckBox`, and assign its Hint/ShowHint
- [x] 3.2 In `optiscaler_tab.pas` `LoadOptiScalerConfig`, assign `Settings.ForceFsr4Int8Checked` to `forceFsr4Int8CheckBox.Checked`
- [x] 3.3 In `optiscaler_tab.pas` `SaveOptiScalerConfig`, capture `forceFsr4Int8CheckBox.Checked` into `Settings.ForceFsr4Int8Checked`

## 4. Verification and Testing

- [x] 4.1 Verify that switching the OptiScaler update channel to Stable Channel hides the "Force FSR4-i8" checkbox and shows the "Emulate FP8" checkbox
- [x] 4.2 Verify that switching the OptiScaler update channel to Bleeding-edge hides the "Emulate FP8" checkbox and shows the "Force FSR4-i8" checkbox (checked by default)
- [x] 4.3 Verify that saving configuration with "Force FSR4-i8" checked adds or updates `Fsr4ForceEnableInt8=true` in the game's `OptiScaler.ini`
- [x] 4.4 Verify that saving configuration with "Force FSR4-i8" unchecked updates `Fsr4ForceEnableInt8=false` in the game's `OptiScaler.ini`
