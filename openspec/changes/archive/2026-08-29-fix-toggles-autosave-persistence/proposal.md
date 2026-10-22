## Why

When users flip `TToggleSwitch` controls on the OptiScaler and MangoHud tabs, their changes are not automatically persisted to disk because `WireAutoSaveEvents` only bound `TCheckBox.OnClick`. In Free Pascal's LCL, programmatic updates to `TCheckBox.Checked` made by `TToggleSwitch` fire `OnChange` but never `OnClick`, and `TToggleSwitch` itself was not processed by `WireAutoSaveEvents`. Consequently, restarting the application causes modified toggle switches to revert to their default states.

## What Changes

- Modify `WireAutoSaveEvents` in `overlayunit.pas` to wire `OnChange` on both `TCheckBox` and `TToggleSwitch` controls to `@GenericControlChange`.
- Guard `forceFsr4Int8CheckBox` creation in `optiscaler_tab.pas` (`if forceFsr4Int8CheckBox = nil then`) to prevent duplicate orphaned control instances when the tab is initialized.
- Ensure all toggle changes across OptiScaler and MangoHud trigger the auto-save timer and persist to disk seamlessly upon user interaction.

## Capabilities

### Modified Capabilities
- `compact-toggles-all-tabs`: Update requirements and scenarios to mandate automatic persistence on toggle state modification across all tabs without requiring explicit finish button clicks.

## Impact

- `overlayunit.pas`: `WireAutoSaveEvents` properly intercepts `TToggleSwitch.OnChange` and `TCheckBox.OnChange`.
- `optiscaler_tab.pas`: Safe singleton initialization of dynamically created checkboxes.
- `toggle_switch.pas`: Ensure `DoOnChange` reliably notifies bound `OnChange` handlers during user interactions.
