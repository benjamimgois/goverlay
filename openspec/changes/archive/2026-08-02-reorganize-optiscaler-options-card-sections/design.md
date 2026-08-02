## Context

Currently in `optiscaler_tab.pas`, `FOsOptionsCard` creates 3 sub-cards (`FOsOptiSec`, `FOsImgSec`, `FOsFakeSec`). `FOsImgSec` hosts the ImGUI Menu controls, while `FOsOptiSec` hosts 8 OptiScaler controls. This design consolidates `FOsImgSec` controls into `FOsOptiSec`, expands `FOsOptiSec` to 67% width, and divides it into 3 sub-columns with vertical dividers.

## Goals / Non-Goals

**Goals:**
- Eliminate `FOsImgSec` sub-card and expand `FOsOptiSec` width to `Round(InnerW * 0.67)`.
- Anchor `FOsFakeSec` to the right 33% (`InnerW - SubCardW - IGAP`).
- Create 3 internal sub-columns inside `FOsOptiSec` ("Main", "Spatial Upscaler", "Temporal Upscaler") with vertical divider lines drawn on `FOsOptiSec.OnPaint`.
- Layout controls neatly vertically in each column.

**Non-Goals:**
- Changing underlying configuration keys or OptiScaler file save/load logic.

## Decisions

1. **Sub-Card Proportions**:
   - `FOsOptiSec` gets `SubCardW := Round((InnerW - IGAP) * 0.67)`
   - `FOsFakeSec` gets `InnerW - SubCardW - IGAP`
   - Inside `FOsOptiSec`, column width `ColW := (SubCardW - 2 * ColGap) div 3`.

2. **Sub-Column Divider Lines**:
   - Drawn in `SubCardPaint` (or `FOsOptiSec.OnPaint`) at `X1 = ColW + ColGap` and `X2 = 2 * ColW + ColGap` using `Canvas.Pen.Color := RGBToColor(55, 70, 108)`.

3. **Reparenting Controls**:
   - Reparent `menuscaleTrackBar`, `menuscalevalueLabel`, `mark1Label`, `mark2Label`, `mark3Label`, `shortcutkeyLabel`, `FOsShortcutCaptureBtn` from `FOsImgSec` to `FOsOptiSec`.
   - Hide `FOsImgSec` and `imgmenuGroupBox`.

## Risks / Trade-offs

- [Narrow Windows] → On narrow windows, 3 internal columns might get tight. *Mitigation:* Use minimum column width guards (`Max(110, ...)`).
