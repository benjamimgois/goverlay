# Design: Fix Background Height and Viewport Gap on Lossless Scaling Tab

## Context

On the Lossless Scaling tab, a `TScrollBox` (`FLsScrollBox`) contains a `TPanel` (`FLsBgPanel`) that hosts the configuration cards and paints the background via `PresetsWrapperPaint`.
Previously, `ReflowLosslessScalingTab` calculated the layout height `CurY` as the sum of the 3 cards and set `FLsBgPanel.Height := CurY` (~422px).
When the GOverlay window is displayed at normal sizes (680px+), the scrollbox viewport height (~600px) exceeds 422px.
When the "Upscalers" sidebar category is disabled, `SetControlTreeEnabled` sets `FLsScrollBox.Enabled := False`. In the Qt6 widgetset, a disabled scroll area renders uncovered viewport regions using the disabled window background palette (gray).

## Goals / Non-Goals

**Goals:**
- Guarantee `FLsBgPanel` spans `Max(FLsScrollBox.ClientHeight, CurY)` so no portion of `FLsScrollBox` viewport is left exposed.
- Include `ReflowLosslessScalingTab(ContentW)` in `Tgoverlayform.FormResize` in `overlayunit.pas`.

**Non-Goals:**
- Modifying the internal card components or controls of Lossless Scaling tab.

## Decisions

### 1. Set FLsBgPanel Bounds with Viewport Height Guard
In `lossless_scaling_tab.pas` (`ReflowLosslessScalingTab`):
```pascal
FLsBgPanel.SetBounds(0, 0, W, Max(FLsScrollBox.ClientHeight, CurY));
```
- **Rationale**: Matches the pattern in `optiscaler_tab.pas` (`FOsBgPanel.SetBounds(0, 0, FOsScrollBox.ClientWidth, Max(FOsScrollBox.ClientHeight, TotalH))`) and `mangohud_ui.pas` (`FMtBgPanel`, `FExtBgPanel`).

### 2. Add Math Unit to lossless_scaling_tab.pas
- Ensure `Math` is in the interface `uses` clause for the `Max` function.

### 3. Add Reflow Call in FormResize
In `overlayunit.pas` (`FormResize`):
```pascal
ReflowLosslessScalingTab(ContentW);
```
- **Rationale**: Keeps tab responsive when window dimensions change.
