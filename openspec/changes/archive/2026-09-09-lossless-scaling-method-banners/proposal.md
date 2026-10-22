## Why

The current method selector on the Lossless Scaling tab displays small square icons (34x34) with separate text labels for `lsfg-vk` and `MAKO`. This creates visual inconsistency with the neighboring `NONE` option and the OptiScaler tab (which uses cohesive rectangular logo banners), limits the clickable area, and produces aesthetic mismatches across desktop themes.

Replacing these separate icon + label elements with unified rectangular banner images (featuring squircle rounded icons and uniform white typography) establishes visual harmony with the rest of GOverlay, provides a larger clickable target, and simplifies the UI code.

## What Changes

- **Add Banner Assets**: Introduce high-resolution transparent banner assets `assets/icons/method_lsfg.png` and `assets/icons/method_mako.png` featuring squircle rounded icons and clean white bold typography.
- **Update Method Selection Layout in Lossless Scaling Tab**:
  - Replace the separate `TImage` + `TLabel` pair for `lsfg-vk` and `MAKO` with single composite `TImage` banners beside each radio button.
  - Remove redundant labels `FLsLsfgLbl` and `FLsMakoLbl`.
  - Adjust layout bounds and spacing in `TLosslessScalingTabHelper.SetupLayout` to allocate appropriate width for the rectangular banners (~117px for LSFG-VK, ~97px for MAKO) at height 36px.
- **Update Selection State and Opacity**:
  - Update `UpdateMethodImageOpacity` to dim and brighten the unified banners directly via `TImage.Enabled`, removing the label font-color toggling.
  - Retain full clickability on both the radio buttons and the banner images.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `lossless-scaling-config`: Update the Method selector visual requirements to specify unified composite banner images for `lsfg-vk` and `MAKO` alongside `NONE`, with synchronized selection opacity and clickability.

## Impact

- **Affected Code**: `lossless_scaling_tab.pas` (method card creation, layout calculations, opacity updates, cleanup of unused labels).
- **Assets**: Added `assets/icons/method_lsfg.png` and `assets/icons/method_mako.png`.
- **Dependencies & APIs**: No external dependency or configuration file changes; `bgmod.conf` and `conf.toml` interactions remain identical.
