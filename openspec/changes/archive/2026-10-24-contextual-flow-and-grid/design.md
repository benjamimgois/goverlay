# Design: Contextual Flow & Grid (Adaptive Row - Option 2)

## Context

See `proposal.md` for motivation. Currently, in `mangohud_ui.pas`, `FVisFlowSec` statically stacks:
- Row 1 (Y=26): Orientation segmented pill (`[ Vertical | Horizontal ]`)
- Row 2 (Y=68): Column count controls (`[-] 3 [+]` + mini-bars paintbox)
- Row 3 (Y=108): Horizontal stretch label and toggle switch

Because `table_columns` only applies to Vertical mode and `horizontal_stretch` only applies to Horizontal mode, presenting both rows at once wastes vertical space and misleads users.

## Goals / Non-Goals

**Goals:**
- Implement dynamic contextual visibility (Adaptive Row) in `FVisFlowSec`:
  - When in Vertical mode: Row 2 renders the Columns controls (`FVisColumnsSubLbl`, `FColumnsMinusBtn`, `columvalueLabel`, `FColumnsPlusBtn`, `FVisColumnsPaintBox`). The Horizontal Stretch controls are hidden.
  - When in Horizontal mode: Row 2 morphs to render the Horizontal Stretch controls (`FVisStretchLbl`, `FhorizontalstrechToggle`). The Columns controls are hidden.
- Centralize visibility and layout adjustments in a dedicated helper method `SyncFlowGridVisibility` within `TMangoHudUiHelper`.
- Update `ReflowVisualTab` to position whichever controls are active at the consistent secondary row Y-coordinate (~68px).
- Guarantee zero regressions in config persistence and GUI test suites.

**Non-Goals:**
- Changing MangoHud's underlying configuration keys or parser.
- Changing the layout of other sub-cards (Screen Placement, Typography, Canvas).

## Decisions

### Decision 1: Single Adaptive Row vs Separate Dimmed Rows
- **Choice**: Morphing Adaptive Row (Option 2).
- **Rationale**: Merging Row 2 and Row 3 into an adaptive contextual row saves ~35-40px of vertical height inside `FVisFlowSec`, creating a cleaner visual balance with `FVisScreenSec` above it. Only the options that actually affect the current layout are shown.
- **Alternative considered**: Option 1 (Dimming/Fade & Lock). While stable, it keeps an inoperable row on screen and consumes more vertical space.

### Decision 2: State Synchronization Flow
- **Choice**: The existing orientation pill click handler (`VisOrientPillBtnClick`) and config synchronization (`SyncVisualPills`, `LoadMangoHudConfig`, `ResetMangoHudControls`) invoke `SyncFlowGridVisibility`.
- **Rationale**: Ensures the UI updates instantly when toggled by user click, config load, or test runner.

## Risks / Trade-offs

- **Risk**: A GUI test toggles `horizontalstrechCheckBox` while in Vertical mode.
  - **Mitigation**: The underlying `TCheckBox` and `TToggleSwitch` remain fully allocated and linked in memory. Setting `.Checked := True` programmatically updates config saving identically regardless of visibility.
