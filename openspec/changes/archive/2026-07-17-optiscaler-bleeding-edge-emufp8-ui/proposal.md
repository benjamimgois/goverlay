## Why

Currently, when the user switches to the "bleeding-edge" OptiScaler channel, the "Emulate FP8" checkbox (`emufp8CheckBox`) is hidden and deactivated. However, on "bleeding-edge", the FP8 checkbox needs to serve a different purpose (enabling FSR MLFG on RDNA3 GPUs). Therefore, it should remain visible and active on the bleeding-edge channel, with its tooltip/hint dynamically updated to reflect its new function.

## What Changes

- Keep `emufp8CheckBox` visible and enabled when the user selects the "bleeding-edge" channel in GOverlay.
- Dynamically update the hint/tooltip of `emufp8CheckBox` to "Used to activate FSR MLFG on RDNA3" when bleeding-edge is selected.
- Position the `forceFsr4Int8CheckBox` at a lower vertical coordinate (`Top := 165`) so it does not overlap with `emufp8CheckBox` when both are visible on the bleeding-edge channel.

## Capabilities

### New Capabilities

<!-- None -->

### Modified Capabilities

- `optiscaler-fsr-version-ui-clean`: Modify requirements to keep the "Emulate FP8" checkbox visible and active on the bleeding-edge channel, updating its description and dynamic hint.

## Impact

- `overlayunit.pas`: Toggle/visibility and hint update logic.
- `optiscaler_tab.pas`: Vertical positioning of `forceFsr4Int8CheckBox`.
