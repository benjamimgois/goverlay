## Why

Edit controls (`TCustomEdit` / `TEdit` / `TLabeledEdit` / `TFloatSpinEdit` / `TSpinEdit`) across GOverlay tabs currently do not trigger auto-save when modified by the user. While checkboxes, radio buttons, comboboxes, and color buttons are registered by `WireAutoSaveEvents`, `TCustomEdit` controls are missing from the event wiring list. As a result, editing text fields (such as CPU/GPU custom names, HUD title, custom environment variables, FPS limits, custom commands, etc.) does not automatically save until another control is modified.

## What Changes

- Update `WireAutoSaveEvents` in `overlayunit.pas` to include `TCustomEdit` controls (excluding search bar with `Tag = 9999`).
- Connect `OnChange` for unassigned `TCustomEdit` controls to `@GenericControlChange`, enabling real-time debounced auto-saving when typing in any edit field.

## Capabilities

### Modified Capabilities
- `auto-save-config`: Extend auto-save event wiring in `WireAutoSaveEvents` to include all text edit fields (`TCustomEdit`) across all GOverlay tabs.

## Impact

- `overlayunit.pas`: `WireAutoSaveEvents` method.
- `tests/gui/gui_test_cases.pas`: Additional GUI tests for text edit control auto-save trigger.
