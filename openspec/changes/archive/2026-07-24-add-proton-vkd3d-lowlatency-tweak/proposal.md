## Why

Proton-CachyOS supports `PROTON_VKD3D_LOWLATENCY=1` to enable low-latency frame pacing capabilities for VKD3D Direct3D 12 titles. Adding this tweak option under the "Latency reduction" section in the EnvVars tab allows users to easily toggle this feature in GOverlay.

## What Changes

- Add `PROTON_VKD3D_LOWLATENCY=1` to the `TWEAK_ROWS` definition array in `tweaks_md3.pas` under the `'Latency reduction'` category.
- Set description to `"[proton-cachyos] low-latency frame pacing capabilities"`.
- Add backing `TCheckBox` component `FProtonVkd3dLowLatencyCheckBox` (or map via `GetTweakRowCheckBox`) and save/load INI persistence in `overlayunit.pas`.

## Capabilities

### New Capabilities
- `proton-vkd3d-lowlatency-tweak`: Toggle support for `PROTON_VKD3D_LOWLATENCY=1` environment variable in the Latency reduction section of the EnvVars tab.

### Modified Capabilities

## Impact

- `tweaks_md3.pas`: `TWEAK_ROWS` definition array and `GetTweakRowCheckBox` mapping.
- `overlayunit.pas` / `overlayunit.lfm`: Checkbox declaration, default initialization, INI save/load, and `goverlay.vars` / `bgmod.conf` generation.
