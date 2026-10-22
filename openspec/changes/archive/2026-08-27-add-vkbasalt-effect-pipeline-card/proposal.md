## Why

vkBasalt applies post-processing shaders sequentially according to the order defined in `effects = effect1:effect2:...` in `vkBasalt.conf`. Currently, GOverlay uses a static, hardcoded order (`cas:fxaa:smaa:dls:reshade_effects`), preventing users from configuring critical pipeline sequences (such as applying anti-aliasing before sharpening or ordering ReShade effects relative to built-in filters). Issue #402 requests a visual card below "Built-in Effects" allowing users to drag and reorder blocks representing active effects to define their execution order.

## What Changes

- Add a new "Effect Pipeline" card (`FVkPipelineCard`) on the vkBasalt tab positioned between "Built-in Effects" and "Toggle key".
- Implement interactive chips with category colors (Green for AA, Blue for Sharpening, Purple for ReShade), drag & drop reordering, quick move buttons (`◀`, `▶`), and a removal button (`✕`).
- Update `TVkBasaltSettings` in `overlay_config.pas` to include `PipelineEffects: TStrings`.
- Update `SaveVkBasaltConfig` to serialize `effects = ...` in the exact order specified by the pipeline.
- Update `LoadVkBasaltConfig` to parse `effects = ...` preserving user-defined execution order and populating the pipeline card.
- Synchronize effect activation/deactivation across sliders, ReShade toggles, and pipeline chips.
- Add GUI and logic test cases to verify pipeline ordering, drag/move reordering, and configuration round-tripping.

## Capabilities

### New Capabilities
- `vkbasalt-effect-pipeline`: Visual, interactive reordering of active vkBasalt built-in and ReShade shader effects defining execution order in `vkBasalt.conf`.

### Modified Capabilities
<!-- None -->

## Impact

- **Affected Files**: `overlay_config.pas`, `overlayunit.pas`, `vkbasalt_tab.pas`, `tests/logic/logic_test_cases.pas`, `tests/gui/gui_test_cases.pas`
- **Affected Functionality**: vkBasalt tab UI, configuration reading and writing for `effects = ...`
- **Breaking Changes**: None. Backwards-compatible with existing configuration files.
