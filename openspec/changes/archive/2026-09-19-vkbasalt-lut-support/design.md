# Design

## Context

See `proposal.md` for motivation.

vkBasalt supports five built-in effects: `cas`, `fxaa`, `smaa`, `dls`, and `lut`. Currently, GOverlay exposes UI controls and serialization only for the first four. When users configure `lut` or `lutFile` manually in `vkBasalt.conf`, GOverlay either overwrites `lutFile` or falsely interprets `lut` as an external ReShade shader (`lut.fx`). Furthermore, the vkBasalt view inside the Post-processing tab suffered from vertical crowding because `FStatusCard` occupied 100px at the bottom while `FVkPipelineCard` was sandwiched between the effects list and the status card.

## Goals / Non-Goals

**Goals:**
- Provide UI controls in `FVkBuiltinCard` for selecting and clearing 3D LUT files (`.cube` and HaldCLUT `.png`).
- Automatically add `lut` to `FPipelineEffects` when a LUT file is selected, and remove it when cleared.
- Synchronize the `LUT` chip in `FVkPipelineCard` with the file path field (closing the chip clears the file).
- Properly serialize `lutFile = "<path>"` with quotes in `vkBasalt.conf` and include `lut` in `effects = ...` at its pipeline position.
- Treat `lut` as a built-in effect in `IsVkBasaltBuiltInEffect` so it is not mistaken for a ReShade `.fx` file.
- In `rmVkBasalt` mode, hide `FStatusCard`, move `FVkPipelineCard` to the bottom of the container, and expand `FVkBuiltinCard` height from 145px to ~195px to accommodate the LUT row.
- Expose ReShade status and version in the `Libraries` card on the Home tab.

**Non-Goals:**
- In-app 3D LUT texture rendering or color preview (rendering is handled by Vulkan and vkBasalt at game runtime).
- Converting between `.cube` and HaldCLUT `.png` formats (vkBasalt natively supports both).
- ReShade `LUT.fx` shader parameter manipulation.

## Decisions

### Decision 1: Single file picker with automatic pipeline activation (Option A)
Rather than introducing a separate "Enable LUT" checkbox, selecting a valid file via `Browse` immediately activates the LUT and appends `lut` to the Effect Pipeline. Clicking the clear button (`✕`) empties the field and removes `lut` from the pipeline.
- *Rationale*: Eliminates unnecessary UI controls, saves horizontal space, and prevents invalid states (e.g. checkbox enabled with no file selected).
- *Alternatives considered*: Checkbox + Path + Browse. Rejected due to added visual complexity and redundancy.

### Decision 2: File format filtering in OpenDialog
The open file dialog filter will accept `*.cube;*.CUBE;*.png;*.PNG`.
- *Rationale*: vkBasalt checks filename extensions for `.cube`/`.CUBE` to use its 3D cube parser and otherwise loads PNG via `stbi_load` expecting a HaldCLUT image where `width == height * height`.
- *Alternatives considered*: Adding a format selector combo box (`lut8`, `lut16`, `cube`). Rejected because vkBasalt auto-detects formats and has no such configuration setting.

### Decision 3: Quote `lutFile` path in `vkBasalt.conf`
When writing `lutFile` in `SaveVkBasaltConfig`, wrap the path in double quotes (`lutFile = "/path/to/lut.cube"`).
- *Rationale*: vkBasalt's config parser skips spaces unless they are enclosed in double quotes. Quoting guarantees that paths with spaces (e.g. `/home/user/My LUTs/warm.cube`) load correctly.

### Decision 4: Layout re-anchoring in `rmVkBasalt`
In `ReflowReShadeTab`, when `FMethod = rmVkBasalt`:
- Set `FStatusCard.Visible := False`.
- Set `BuiltinH := 195` (increased from 145).
- Move `FVkPipelineCard` to the bottom of the tab view.
- When switching to `rmReshade` or `rmNone`, restore `FStatusCard.Visible := True`.
- *Rationale*: Software status for vkBasalt and ReShade is now accessible from the Home tab. Removing it in vkBasalt mode recovers 100px vertical space, allowing the pipeline to anchor cleanly at the base while `FVkBuiltinCard` gains the height needed for the LUT row.

### Decision 5: Add ReShade to Home tab Libraries list
Expand `MOD_NAMES` in `home_tab.pas` from 7 to 8 entries, insert `'ReShade'`, and check `IsReShadeInstalled` to set the dot indicator and version label (`'6.4 (Add-on Edition)'` or `'not found'`).
- *Rationale*: The Home tab is the centralized place for all runtime and tool statuses (MangoHud, vkBasalt, OptiScaler, DLSS Enabler, vkSumi, lsfg-vk, MAKO).

## Risks / Trade-offs

- **[Invalid PNG dimensions]**: vkBasalt logs an error and ignores non-square-cubed PNGs (`width != height * height`).
  - *Mitigation*: Set dialog filter descriptions clearly to indicate HaldCLUT PNG and 3D Cube formats.
- **[GUI test assertions]**: Existing test `TestVkBasaltPipelineCardVisibleAndBounds` asserts that `StatusCard` is below `PipelineCard`.
  - *Mitigation*: Update the GUI test to assert that `StatusCard.Visible` is `False` in `rmVkBasalt` and `PipelineCard` is the bottom-most card.
