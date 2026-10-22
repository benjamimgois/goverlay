## Why

The OptiScaler tab currently uses standard LCL checkboxes (`TCheckBox`) in its Options card. Following the modern UI redesign and the adoption of compact antialiased glowing toggle switches (`TToggleSwitch`, 28x16px) across MangoHud and Lossless Scaling tabs, the OptiScaler tab needs to be updated to maintain consistent visual design, touch/click ergonomics, and shadow effects across GOverlay.

## What Changes

- Migrate active checkboxes on the OptiScaler tab (`optipatcherCheckBox`, `spoofCheckBox`, `forceFsr4Int8CheckBox`, `emufp8CheckBox`, `forcereflexCheckBox`, `forcelatencyflexCheckBox`) to `TToggleSwitch` controls.
- Maintain backward-compatible two-way synchronization with existing underlying `TCheckBox` controls to preserve INI serialization, event handling, and test compatibility.
- Ensure companion controls (e.g. `FOsPatcherListBtn` 🔗 button) align dynamically next to the new toggle controls in `ReflowOptiScalerTabNew`.
- Synchronize all toggle states automatically when OptiScaler configuration is loaded or updated.

## Capabilities

### Modified Capabilities
- `compact-toggles-all-tabs`: Add requirement for OptiScaler tab toggle switches covering OptiPatcher, Spoof DLSS, Force FSR4-i8, Force MLFG in RDNA3, Force Reflex, and Force LatencyFlex.

## Impact

- **UI Components**: `optiscaler_tab.pas` creates and manages `TToggleSwitch` instances linked to `TCheckBox` controls.
- **Layout**: `ReflowOptiScalerTabNew` in `optiscaler_tab.pas` reflows `TToggleSwitch` bounds (height 20px, optimal width) and positions `FOsPatcherListBtn`.
- **Dependencies**: Uses `toggle_switch.pas` in `optiscaler_tab.pas`.
- **Testing**: Preserves 100% test compatibility for `make test-logic` and `make test-gui`.
