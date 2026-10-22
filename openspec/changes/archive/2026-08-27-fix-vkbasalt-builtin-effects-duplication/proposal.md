## Why

When built-in effects (such as CAS, FXAA, SMAA, or DLS) are enabled in the vkBasalt tab, GOverlay serializes them twice into the `effects` line in `vkBasalt.conf` (e.g. `effects = cas:cas`) and generates bogus file mappings (e.g. `cas = .../reshade-shaders/cas`). This causes vkBasalt to run the shader twice in sequence on the GPU, leading to severe oversharpening/visual distortion and redundant GPU overhead.

## What Changes

- In `overlayunit.pas`, stop adding built-in effect names (`cas`, `fxaa`, `smaa`, `dls`) to `acteffectsListbox.Items` when adjusting trackbars (`casTrackBarChange`, `fxaaTrackBarChange`, `smaaTrackBarChange`, `dlsTrackBarChange`).
- In `overlay_config.pas` (`SaveVkBasaltConfig`), ensure built-in effect names are ignored/filtered when iterating through `Settings.ReshadeEffects`, preventing accidental duplication and bogus path mappings.
- In `tests/gui/gui_test_cases.pas`, update and add test assertions to verify that `effects` line contains only single instances of built-in effects and no bogus shader path mappings.

## Capabilities

### New Capabilities
- `vkbasalt-builtin-effects-serialization`: Proper single-instance serialization of built-in vkBasalt post-processing effects (`cas`, `fxaa`, `smaa`, `dls`) without duplication or invalid ReShade file path entries.

### Modified Capabilities
<!-- None -->

## Impact

- **Affected Files**: `overlayunit.pas`, `overlay_config.pas`, `tests/gui/gui_test_cases.pas`
- **Affected Functionality**: vkBasalt configuration generation and save/load round-trip.
- **Breaking Changes**: None. Fixes existing bug where effects were applied twice.
