# Proposal

## Why

In the Post Processing tab, when the **vkBasalt** method is selected, the "Built-in Effects" card (`FVkBuiltinCard`) has a hardcoded height of 195px (`BuiltinH` / `BTIN_H`). However, its child controls (CAS, FXAA, SMAA, DLS, and Color LUT) finish at Y=156px, leaving ~39px of completely unused dark space at the bottom of the card. Furthermore, the vertical inter-row gaps are wider than necessary (14px).

Because the height of the "Reshade Effects" card (`FVkReshadeCard`) is computed dynamically as the remaining space above the fixed bottom cards, this dead space unnecessarily constrains the ReShade effects list. Reducing the Built-in Effects card height from 195px to 148px (a 47px reduction) reclaims enough vertical space to display an entire extra row of effects (`ItemH = 44px`) in the ReShade effects grid without requiring scrolling.

## What Changes

- Compact the "Built-in Effects" card layout:
  - Reduce the top offset of Row 0 (CAS, FXAA) to Y=38.
  - Set the vertical gap between rows to 8px (Row 1 at Y=74, Row 2 at Y=110).
  - Reduce card height constant (`BTIN_H` and `BuiltinH`) from 195px to 148px.
- The freed 47px is automatically transferred to `FVkReshadeCard` in `ReflowReShadeTab`, expanding the ReShade effects card and revealing an additional row of effects.
- Update GUI test assertions in `tests/gui/gui_test_cases.pas` to validate the new card height (`>= 148` instead of `>= 195`).

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `vkbasalt-tab-layout-reflow`: Update Built-in Effects card sizing requirement to specify compact vertical geometry (148px) that optimizes vertical space distribution between the Built-in Effects and Reshade Effects cards.

## Impact

- `reshade_tab.pas`: Update `BuiltinH` from 195 to 148 in `ReflowReShadeTab`.
- `vkbasalt_tab.pas`: Update `BTIN_H` from 195 to 148 and update `Row0`, `Row1`, `Row2` vertical coordinates in `ReflowVkBasaltTab`.
- `tests/gui/gui_test_cases.pas`: Update `TestVkBasaltPipelineCardVisibleAndBounds` assertion from `>= 195` to `>= 148`.
