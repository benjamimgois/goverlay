## Why

Currently, while `QComboBox` controls use the unified Slate Navy theme (`rgb(38,46,72)`), `QLineEdit` (text input fields) and `QSpinBox` (numeric spin input fields) across various tabs (MangoHud, OptiScaler, EnvVars, Presets, etc.) use generic dark gray colors (`rgb(46,46,46)`) or ad-hoc transparency styles.

Applying the Slate Navy theme to all `QLineEdit` and `QSpinBox` widgets with a dedicated focus state (`:focus`) will create visual consistency across all input control types in GOverlay.

## What Changes

- Apply global Slate Navy theme (`rgb(38,46,72)` background, `rgb(55,70,108)` border, `rgb(255,255,255)` text) to all `QLineEdit` and `QSpinBox` widgets via `QApplication_setStyleSheet` in `overlayunit.pas`.
- Add active focus highlighting (`:focus`) with cyan accent border (`rgb(48,190,240)`) to provide clear visual feedback when an edit field or spin box is active/focused.
- Add disabled styling (`:disabled`) with darker background (`rgb(28,34,54)`) and dimmed text (`rgb(100,110,130)`).
- Update sub-panel / component styling helpers in `overlayunit.pas` and `mangohud_ui.pas` to maintain theme consistency for container-level overrides.

## Capabilities

### New Capabilities
- `unified-edit-controls-theme`: Global Slate Navy styling and focus feedback for `QLineEdit` and `QSpinBox` controls.

### Modified Capabilities

## Impact

- `overlayunit.pas`: Global `QApplication_setStyleSheet` configuration in `FormShow` and container-level `UpdateGenericCardTheme` helper.
- `mangohud_ui.pas`: Custom `QLineEdit` and `QSpinBox` styling calls for MangoHud tabs.
- All tabs with input fields (`QLineEdit` and `QSpinBox`) receive uniform visual styling without breaking functional behavior.
