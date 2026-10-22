# Design: TBitBtn Qt Palette Synchronization for High Contrast

## Context

See `proposal.md - Why` for motivation.

In Lazarus LCL-Qt (Qt5 and Qt6), `TQtBitBtn` intercepts `QEventPaint` in `EventFilter` to paint custom glyph and text layouts. The text is drawn directly using `QPainter_drawText(APainter, ..., @AText)`. The painter takes its pen color from `widget->palette().color(QPalette::ButtonText)`. In KDE Plasma desktop environments with hybrid or light palettes (e.g. Kubuntu Breeze), `ButtonText` is dark charcoal/black (`#2b2e32`).

Setting LCL `Font.Color` only alters `QPalette::WindowText` (via `TQtWidget.setDefaultColorRoles`), leaving `QPalette::ButtonText` un-updated. Applying a QSS stylesheet (`QPushButton { color: white; }`) styles Qt's internal button rendering, but LCL's `TQtBitBtn` overrides it by painting over the button surface.

## Goals / Non-Goals

**Goals:**
- Provide clear, high-contrast text on all `TBitBtn` controls across all tabs and themes.
- Implement a reusable, centralized helper (`StyleBitBtnTheme`) that updates both the QSS stylesheet and the underlying Qt widget palette (`QPalette::ButtonText` and `QPalette::WindowText`).
- Integrate palette synchronization into `UpdateGenericCardTheme` and tab-specific theme updaters.

**Non-Goals:**
- Replacing existing `TBitBtn` instances with custom painted controls where native buttons already function.
- Changing button layout geometry or existing click handlers.

## Decisions

### Decision 1: Centralized `StyleBitBtnTheme` Helper
Create a helper procedure in `themeunit.pas` (or `overlay_utils.pas`):
```pascal
procedure StyleBitBtnTheme(ABtn: TBitBtn; ATextColor: TColor; ABgColor: TColor);
```
Responsibilities:
1. Set `ABtn.Font.Color := ATextColor;`
2. Apply the standard action/secondary button QSS stylesheet (`QPushButton, QToolButton { ... }`) via `QWidget_setStyleSheet`.
3. Extract `TColorRef`, convert to `TQColor` via `QColor_fromRgb`, retrieve `QWidget_palette(Wdgt)`, and call:
   ```pascal
   QPalette_setColor(Pal, QPaletteButtonText, @QC);
   QPalette_setColor(Pal, QPaletteWindowText, @QC);
   QWidget_setPalette(Wdgt, Pal);
   ```
*Rationale*: Solves the problem uniformly across both Qt5 and Qt6 widgetsets for any button, without duplicating stylesheet strings and palette API calls.

### Decision 2: Update `UpdateGenericCardTheme` in `overlayunit.pas`
In `overlayunit.pas`, update `ApplyToContainer`:
```pascal
else if Container.Controls[k] is TBitBtn then
begin
  StyleBitBtnTheme(TBitBtn(Container.Controls[k]), TextColor, RGBToColor(38, 46, 72));
end;
```
*Rationale*: Automatically covers all `TBitBtn` controls nested within cards (e.g., `gpuframesjouleBitBtn`, `coreloadtypeBitBtn`, `cpuframesjouleBitBtn`, `intelpowerfixBitBtn` in `FMtGpuCard` and `FMtCpuCard`).

### Decision 3: Update Specific Buttons across MangoHud Tabs
In `mangohud_ui.pas`:
- **Visual Tab**: Style `FColumnsMinusBtn`, `FColumnsPlusBtn`, and `FVisualCaptureBtn` via `StyleBitBtnTheme`.
- **Performance Tab**: Style `fpsavgBitBtn`, `frametimetypeBitBtn`, and `FLimitCaptureBtn` via `StyleBitBtnTheme`.
- **Extras Tab**: Style `FTimeConfigBtn`, `logfolderBitBtn`, and `FLoggingCaptureBtn` via `StyleBitBtnTheme`.

### Decision 4: Safe Handle Access
Evaluate `ABtn.Handle` directly (or ensure control is parented before accessing handle) so that Qt palette modification takes effect reliably on first paint.

## Risks / Trade-offs

- **[Risk] Premature handle creation**: Calling `.Handle` before a control is parented can raise an LCL exception or create an orphan widget.
  → **Mitigation**: Only call `StyleBitBtnTheme` after the button has been assigned a `Parent` (in `Init*Tab` and `Update*CardTheme` / `TabSheetShow`).
