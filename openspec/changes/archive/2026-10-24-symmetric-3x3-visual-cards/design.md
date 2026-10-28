# Design: Symmetric 3x3 Visual Independent Cards Layout

## Context

In the previous revision, two wrapper cards (`FVisAppearanceCard` and `FVisLayoutCard`) were used to host 3 sub-panels each. However, because both the wrapper cards and the sub-panels used `SubCardPaint` with the identical background fill color and subtle borders, the sub-panels blended completely into the parent cards without contrast, appearing as a single continuous block. Furthermore, the nested margins consumed valuable horizontal width, causing controls like `Corner border` (`Square | Round`) and `Active GPU` to overflow and clip.

## Goals / Non-Goals

**Goals:**
- Promote the 6 topics into independent first-class cards parented directly to `visualTabSheet` (`FVisualCards[0..5]`).
- Left column (3 cards):
  - Card 1: `HUD Header & Title` (`FVisTitleSec`, ~95px)
  - Card 2: `Typography` (`FVisTypographySec`, ~165px)
  - Card 3: `Canvas & Frame` (`FVisCanvasSec`, flex to bottom)
- Right column (3 cards - Option A):
  - Card 4: `Flow & Grid` (`FVisFlowSec`, ~95px - perfectly mirrors Card 1 height)
  - Card 5: `Display & System` (`FVisSystemSec`, ~165px - perfectly mirrors Card 2 height)
  - Card 6: `Screen Placement` (`FVisScreenSec`, flex to bottom - spacious 16:9 vector monitor)
- Synchronize fixed top budgets across columns (260px sum) so that Row 3 (`Canvas & Frame` and `Screen Placement`) starts at the exact same Y position and has identical height.
- Eliminate all control clipping & polish details:
  - Dynamically align `FVisBorderPillBtn` with safe right padding (`ColW - FVisBorderPillBtn.Width - 12`).
  - Rename "Corner borders:" label to "Corners:".
  - Enrich `FVisCanvasSec` with native `Corner radius` slider and `No outer margins` (`hud_no_margin`) toggle switch, fully utilizing card height.
  - Remove redundant explanatory hint labels from `FVisTitleSec` and `FVisCanvasSec`.
  - Maintain clean adaptive controls in `FVisFlowSec`: Columns in Vertical mode and Stretch in Horizontal mode without overlapping labels.
  - Increase `QComboBox` left padding to 10px so GPU device names never touch the left border.
  - Position `Offset X` and `Offset Y` centered under the monitor stand, keeping clearance from the floating dock.
- Retain backward compatibility for `FVisAppearanceCard` and `FVisLayoutCard` pointers.

**Non-Goals:**
- Modify MangoHud backend settings, config persistence, or keys.
- Modify other tabs.

## Decisions

### Decision 1: Direct First-Class Cards on VisualTabSheet
- **Choice**: Eliminate the outer container panels (`FVisAppearanceCard` and `FVisLayoutCard` as visual wrappers), reparenting all 6 topic cards directly to `visualTabSheet`.
- **Rationale**: Direct cards on `visualTabSheet` render with crisp borders, rounded corners, and clear elevation over the dark background. Eliminating the double-nesting restores ~20px of usable width per column, completely eliminating button and dropdown clipping.

### Decision 2: 260px Fixed Top Budget for Exact Row 3 Alignment
- **Choice**:
  - Left column: Card 1 is 95px (`FVisTitleSec`), Card 2 is 165px (`FVisTypographySec`). Sum = 260px.
  - Right column: Card 4 is 95px (`FVisFlowSec`), Card 5 is 165px (`FVisSystemSec`). Sum = 260px.
  - Row 3 on both sides begins at `Sec3Top := MARGIN + 260 + 2 * GAP`.
  - Row 3 on both sides (`FVisCanvasSec` and `FVisScreenSec`) has flex height `ActiveCardsH - Sec3Top`.
- **Rationale**: Both columns have identical Row 1 (95px), Row 2 (165px), and Row 3 starting tops and heights, resulting in perfect visual symmetry. In Row 3, `FVisScreenSec` has ~240px+ height, allowing the vector monitor to render at true 16:9 widescreen aspect ratio with ample breathing room.

## Risks / Trade-offs

- **[Risk] Window resize below min height**:
  - *Mitigation*: Enforce `ActiveCardsH := Max(520, TabH - 2 * MARGIN)` and min-height guards on the flex third row.
