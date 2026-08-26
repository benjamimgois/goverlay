# Proposal: Modern Pure QSS Vector Arrows for ComboBox and SpinBox Controls

## Why
External image assets for ComboBox and SpinBox arrows suffered from low contrast and excessive padding, resulting in tiny, barely visible dots in the UI. Switching to pure CSS/QSS vector arrows rendered directly by the Qt engine ensures crisp geometric rendering, high visibility, zero external file dependencies, and seamless hover highlights matching the Slate Navy and Cyan accent theme.

## What Changes
- Replace image-based `down-arrow`, `up-arrow`, and `down-arrow` with pure QSS geometric border triangles and styled subcontrols in `themeunit.pas`.
- Ensure high contrast with bright slate-silver / white arrows (`rgb(220, 230, 245)`) that highlight in cyan (`rgb(48, 190, 240)`) on hover/focus.
- Clean up unused arrow image generator files if any.

## Capabilities

### Modified Capabilities
- `unified-edit-controls-theme`: Extend input control styling requirements to mandate crisp pure-QSS vector arrows for `QComboBox` drop-downs and `QSpinBox` steppers with hover state highlights.

## Impact
- `themeunit.pas`: `GetComboBoxStyleSheet`, `GetSpinBoxStyleSheet`, `StyleInputControl`.
- `overlayunit.pas`: `GlobalSS`, `ApplyCustomEnvTheme`.
- `mangohud_ui.pas`: `fpscolor2SpinEdit`, `fpscolor3SpinEdit`, `pcidevComboBox`.
- `lossless_scaling_tab.pas`: Pacing and GPU ComboBoxes.
