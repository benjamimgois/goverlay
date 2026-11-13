# Proposal

## Why

Upstream Proton-CachyOS and Proton-GE releases recently added useful environment variables that are not yet exposed in Goverlay's Tweaks tab: `PROTON_ZLUDA=1` (experimental 32-bit PhysX support on AMD via ZLUDA) and several Proton-GE controller compatibility variables. Grouping controller-related tweaks into a dedicated `Controllers` category with clear `GE` badges makes these options easy to discover and configure without cluttering the `General` category.

## What Changes

- Add `PROTON_ZLUDA=1` under the `Experimental` category (`TWEAK_CAT_EXPERIMENTAL`) with the `[proton-cachyos]` badge prefix and English description.
- Introduce a new `Controllers` category (`TWEAK_CAT_CONTROLLERS`) in `tweaks_md3.pas` and move `PROTON_USE_SDL=1` from `General` into `Controllers`.
- Add a `[GE]` / `[proton-ge]` badge style in `tweaks_md3.pas` for Proton-GE exclusive variables.
- Add the selected Proton-GE controller variables to the `Controllers` category with `[GE]` badges and English descriptions:
  - `PROTON_SONY_WINDOWS_DEVICE_NAMES=1`
  - `PROTON_STEAM_INPUT_XBOX_PROMPTS=1`
  - `PROTON_SONY_AUTO_XINPUT=0`
  - `PROTON_SONY_HIDRAW_XINPUT=1`
  - `PROTON_DUALSENSE_HAPTICS_PREFER_NON_EVENT=1`
- Wire checkboxes, `configkeys.pas` constants, `IsKnownTweakKey`, `SaveTweaksConfig`, `LoadTweaksFromFGMod`, and reset-on-clear handling in `tweaks_md3.pas` and `overlayunit.pas`.

## Capabilities

### New Capabilities
- `proton-tweaks-controllers`: Dedicated `Controllers` category with `GE` badges for Proton-GE controller environment variables, plus `PROTON_ZLUDA=1` in the `Experimental` category.

### Modified Capabilities
<!-- None: existing Tweaks categories and persistence behavior remain intact. -->

## Impact

- `tweaks_md3.pas`
- `overlayunit.pas`
- `configkeys.pas`
