# Proposal

## Why

vkBasalt natively supports 3D color LookUp Tables (Adobe `.cube` and HaldCLUT `.png`) via its built-in `lut` effect, but GOverlay currently lacks UI controls for it and overwrites `lutFile` entries upon saving `vkBasalt.conf`. Adding dedicated LUT controls, refactoring the vkBasalt tab layout (hiding Software Status and moving Effect Pipeline to the bottom), and exposing ReShade's version in the Home tab's Libraries list solves screen crowding and completes GOverlay's coverage of vkBasalt's built-in effects.

## What Changes

- **Built-in Effects Card**: Add Color LUT controls (icon, label, read-only path edit, Browse button, and Clear button) to `FVkBuiltinCard`.
- **Automatic Pipeline Activation**: Selecting a valid `.cube` or `.png` LUT file automatically adds `lut` to the active Effect Pipeline. Clearing the file removes `lut` from the pipeline.
- **Pipeline Chip Interaction**: Display `LUT` chip in the pipeline; clicking the chip's close button clears the LUT file and removes the effect.
- **Serialization & Deserialization**: Update `overlay_config` to recognize `lut` as a built-in effect, serialize `lutFile = "/path/to/lut"`, and load existing `lutFile` and `lut` effects from `vkBasalt.conf`.
- **vkBasalt Tab Reflow**: In vkBasalt mode (`rmVkBasalt`), hide the `Software Status` card (`FStatusCard.Visible := False`), increase the height of `FVkBuiltinCard` to ~195px, and anchor `FVkPipelineCard` to the bottom of the tab.
- **Home Tab Libraries**: Add `ReShade` to the `Libraries` card on the Home tab (`home_tab.pas`), displaying its installation status and version (`6.4 (Add-on Edition)`).

## Capabilities

### New Capabilities
- `vkbasalt-3d-lut`: Dedicated UI controls and lifecycle management for vkBasalt 3D LookUp Table (LUT) color grading files (.cube and HaldCLUT .png).
- `home-libraries-reshade-status`: Display ReShade installation status and version within the Libraries module list on the Home tab.

### Modified Capabilities
- `vkbasalt-builtin-effects-serialization`: Treat `lut` as a built-in effect (preventing false detection as a ReShade shader) and serialize/deserialize `lutFile`.
- `vkbasalt-tab-layout-reflow`: Refactor vkBasalt tab layout to hide the Software Status card and position the Effect Pipeline card at the bottom.

## Impact

- **Affected units**: `overlay_config.pas`, `vkbasalt_tab.pas`, `reshade_tab.pas`, `home_tab.pas`, `overlayunit.pas`.
- **Configuration files**: `vkBasalt.conf` (`effects = ...` and `lutFile = "..."`).
- **Tests**: `tests/logic/logic_test_cases.pas` (serialization roundtrip) and `tests/gui/gui_test_cases.pas` (layout and pipeline bounds assertions).
