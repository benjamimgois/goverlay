## Why

Following the successful validation and testing of compact high-resolution antialiased toggle switches (`TToggleSwitch`, 28x16px) on the MangoHud Metrics tab, we are extending the same modern toggle component across all remaining tabs (MangoHud Visual, Performance, Extras, and Lossless Scaling) to establish visual and functional consistency throughout GOverlay.

## What Changes

- **MangoHud Visual Tab**: Replace checkboxes (`hudcompactCheckBox`, `horizontalstrechCheckBox`, `hidehudCheckBox`, `fpscolorCheckBox`) with `TToggleSwitch`.
- **MangoHud Performance Tab**: Replace checkboxes (`fpsCheckBox`, `fpsavgCheckBox`, `showfpslimCheckBox`, `frametimegraphCheckBox`, `frametimedetailedCheckBox`, `vpsCheckBox`, `ftraceCheckBox`, `framecountCheckBox`) with `TToggleSwitch`.
- **MangoHud Extras Tab**: Replace checkboxes across System/Engine, Logging, Battery/Device, Custom Text, Time, Media, and Present/Sync cards with `TToggleSwitch`.
- **Lossless Scaling Subtab**: Replace checkboxes (`FLsPerfModeCheckBox`, `FLsHdrModeCheckBox`, `FLsNoFp16CheckBox`) with `TToggleSwitch`.
- **State Synchronization**: Wire full bi-directional state synchronization between the toggle switches and backend configuration loaders/savers.
- **GUI Tests**: Expand automated GUI test coverage to verify toggle states, layout reflow, and config persistence across all updated tabs.

## Capabilities

### New Capabilities
- `compact-toggles-all-tabs`: Extends `TToggleSwitch` across MangoHud Visual, Performance, Extras, and Lossless Scaling tabs.

### Modified Capabilities
<!-- None -->

## Impact

- **UI Units**: `mangohud_ui.pas` and `lossless_scaling_tab.pas`.
- **Configuration**: Seamless compatibility with `MangoHud.conf` and `gameconfig` INI files.
- **Tests**: Comprehensive GUI test suite validation.
