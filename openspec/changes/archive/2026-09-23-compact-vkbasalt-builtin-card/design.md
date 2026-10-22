# Design

## Context

See `proposal.md` for motivation.

When the vkBasalt method is selected on the Post Processing tab:
- `reshade_tab.pas` allocates `BuiltinH` for `FVkBuiltinCard` and computes `ReshadeH := TotalH - CurY - FixedBelow`.
- `vkbasalt_tab.pas` defines `BTIN_H` and positions child controls in `ReflowVkBasaltTab`.
- The controls in `FVkBuiltinCard` comprise a card title, 2 rows of trackbars (CAS/FXAA, SMAA/DLS), and 1 row for Color LUT (edit box + Browse and Clear buttons).
- Each item in the ReShade effects grid has an item height of 44px (`ItemH := 44`).

## Goals / Non-Goals

**Goals:**
- Eliminate the ~39px empty bottom area in `FVkBuiltinCard`.
- Compact inter-row vertical spacing from 14px to 8px.
- Reduce total card height from 195px to 148px.
- Transfer the reclaimed 47px directly to `FVkReshadeCard`, allowing an additional row of ReShade effects to be fully visible.
- Keep GUI test suite updated and passing.

**Non-Goals:**
- Reorganizing columns or horizontal layout within the card.
- Altering any functionality or file handling of the LUT or trackbar controls.

## Decisions

### Decision: Card Height of 148px and Row Offsets
- **Choice**:
  - Title at `Y = 10` (height 22)
  - Row 0 (CAS, FXAA): `Y = 38` (height 28)
  - Row 1 (SMAA, DLS): `Y = 74` (height 28, gap = 8px)
  - Row 2 (Color LUT): `Y = 110` (height 28, gap = 8px)
  - Bottom padding = 10px -> Total height = `110 + 28 + 10 = 148px`.
- **Rationale**: Saving 47px exceeds `ItemH = 44px`, directly revealing a full additional row in `FVkReshadeCard`.
- **Alternatives Considered**:
  - 168px (only remove bottom dead space): Only saves 27px, not enough for a full extra row.
  - 156px (moderate reduction): Saves 39px, close but still slightly under 44px.

### Decision: Synchronization Between Helper Units
- Both `reshade_tab.pas` (`BuiltinH := 148`) and `vkbasalt_tab.pas` (`BTIN_H = 148`) will use the identical constant value so standalone and unified tab behaviors remain completely consistent.

## Risks / Trade-offs

- **[Risk]** Compact spacing might feel crowded on very high DPI screens.
  - **Mitigation**: 8px between rows and 10px bottom padding maintains clear visual separation and aligns with standard GOverlay form padding (e.g. 6px-8px in options cards).
- **[Risk]** GUI test failure due to hardcoded height assertion.
  - **Mitigation**: Update `AssertTrue('BuiltinCard is expanded', Height >= 148)` in `tests/gui/gui_test_cases.pas`.
