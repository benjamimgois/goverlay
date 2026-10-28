# Proposal: Symmetric 3x3 Visual Independent Cards Layout

## Why

Following the elimination of the bottom Action Bar, the Visual tab was partitioned into two large wrapper cards containing nested sub-panels. However, this nested architecture introduced two problems:
1. **Lack of Visual Contrast**: The nested sub-panels were painted with the identical background color as the outer parent cards, causing them to blend together and look like a single massive card per column rather than distinct topics.
2. **Clipping & Cramped Controls**: Double nesting (TabSheet -> Wrapper Card -> Sub-Panel) consumed margins and paddings on both levels, losing ~20-24px of horizontal space. This clipped the segmented pill button (`Square | Round`) on the right edge and squeezed the `Active GPU` combo box and other controls.
3. **Dead Space from Wrapper Headers**: Outer headers (`Appearance & Typography` and `Position & Layout`) consumed vertical height without adding functional value.

Promoting the 6 topics into **direct, first-class cards** directly on `visualTabSheet` (3 per column) resolves all clipping issues, provides full column width and height, gives clean visual contrast with elevated rounded cards on the dark tab background, and aligns the 3x3 layout symmetrically.

## What Changes

- **Direct 6-Card Architecture**:
  - Eliminate the two intermediate wrapper cards (`FVisAppearanceCard` and `FVisLayoutCard`).
  - Promote each of the 6 topics to direct child cards of `visualTabSheet` (`FVisualCards[0..5]`):
    - **Left Column**:
      1. `FVisTitleSec` (HUD Header & Title, ~95px)
      2. `FVisTypographySec` (Typography, ~165px)
      3. `FVisCanvasSec` (Canvas & Frame, flex remaining to bottom)
    - **Right Column (Opção A)**:
      1. `FVisFlowSec` (Flow & Grid, ~95px - mirrors HUD Title)
      2. `FVisSystemSec` (Display & System, ~165px - mirrors Typography)
      3. `FVisScreenSec` (Screen Placement, flex remaining to bottom - spacious 16:9 monitor)
- **Eliminate Clipping & Horizontal Margins**:
  - Reparent controls directly into the first-class cards.
  - Dynamically align `FVisBorderPillBtn` with safe right padding (`ColW - FVisBorderPillBtn.Width - 12`) so "Square | Round" is never clipped.
  - Give `pcidevComboBox` full horizontal clearance with label on the left.
- **Vertical Alignment & Polish**:
  - Both columns share synchronized fixed top card allocation, ensuring Row 3 (`Canvas & Frame` and `Screen Placement`) starts at the identical Y coordinate and shares the exact same height.
  - `Canvas & Frame`: enriched with `Corner radius` slider (0-25px) and `No outer margins` toggle (`hud_no_margin`), alongside background color, opacity, corners, and compact mode.
  - `HUD Header & Title`: streamlined with clean single-row title input, removing redundant explanatory labels.
  - `Flow & Grid`: clean adaptive row displaying Columns controls in Vertical mode and Horizontal Stretch in Horizontal mode without overlapping text.
  - `Display & System`: enhanced QComboBox left padding to prevent first-letter clipping on long GPU names.
  - `Screen Placement`: monitor anchored at top (16:9 widescreen) with offset controls centered below the stand away from the floating action dock.
- **Responsive Reflow**: Update `ReflowVisualTab` in `mangohud_ui.pas` to position the 6 cards directly on `visualTabSheet`.

## Capabilities

### Modified Capabilities
- `mangohud-visual-modular-ui`: Update the modular requirement to specify 6 independent first-class cards in a symmetric 3x3 layout across two columns.

## Impact

- **Affected Code**: `mangohud_ui.pas` (`InitVisualTab`, `ReflowVisualTab`, `UpdateVisualCardTheme`), `tests/gui/gui_test_cases.pas`.
- **Zero Config Impact**: Configuration persistence, keys, and values are unchanged.
