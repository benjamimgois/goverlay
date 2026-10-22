# Design: Surgical Fix for UI Controls Text Contrast

## Context

See `proposal.md - Why` for motivation.

In Lazarus LCL-Qt (Qt6/Qt5), setting `Font.Color` or parent background colors on a control does not automatically update Qt's internal palette or override the desktop style's `QCommonStyle` rendering engine when a desktop theme like KDE Breeze is active. When Breeze renders widgets (such as `QRadioButton`, `QPushButton`, and `QToolButton`), it paints foreground text using `QPalette::WindowText` or `QPalette::ButtonText` unless an explicit QSS stylesheet is applied via `QWidget_setStyleSheet`.

## Goals / Non-Goals

**Goals:**
- Fix text illegibility in `filterRadioGroup` (Performance tab) under dark and hybrid desktop styles.
- Fix text illegibility on shortcut capture buttons (`FVisualCaptureBtn`, `FLimitCaptureBtn`, `FLoggingCaptureBtn`).
- Fix illegible symbols in `FColumnsMinusBtn` and `FColumnsPlusBtn` (Visual tab).
- Fix `UpdateGenericCardTheme` to style both `QCheckBox` and `QRadioButton` controls.

**Non-Goals:**
- Rewriting the entire theme subsystem or introducing new global theme classes.
- Altering visual appearance under GNOME Adwaita or systems where contrast is already correct.

## Decisions

### Decision 1: Explicit QSS for `filterRadioGroup`
- Apply `QGroupBox { border: none; } QRadioButton { color: %s; background-color: transparent; }` on `filterRadioGroup.Handle` in both `InitPerformanceTab` and `UpdatePerfCardTheme`.
- Set `filterRadioGroup.Font.Color := TextColor`.
- *Alternatives considered*: Only setting `Font.Color`. Discarded because Qt Breeze ignores `TControl.Font.Color` on radio buttons without QSS or palette updates.

### Decision 2: Apply Standard Action Button QSS to Capture Buttons
- For `FVisualCaptureBtn`, `FLimitCaptureBtn`, and `FLoggingCaptureBtn`, apply the standard GOverlay action button stylesheet:
  ```css
  QPushButton, QToolButton {
    background-color: rgb(38,46,72);
    color: rgb(255,255,255);
    border: 1px solid rgb(55,70,108);
    border-radius: 4px;
    padding: 3px 8px;
  }
  QPushButton:hover, QToolButton:hover {
    background-color: rgb(50,62,96);
    border: 1px solid rgb(80,110,170);
  }
  ```
  (and equivalent light theme colors if `CurrentTheme = tmLight`).
- Set `Font.Color := TextColor` directly on each `TBitBtn`.
- *Alternatives considered*: Converting `TBitBtn` to custom-painted panels. Discarded because `TBitBtn` already works well with QSS and minimal code changes are needed.

### Decision 3: Include `QToolButton` and `Font.Color` for Columns Stepper Buttons
- In `InitVisualTab` and `UpdateVisualCardTheme`, set `FColumnsMinusBtn.Font.Color := TextColor` and `FColumnsPlusBtn.Font.Color := TextColor`.
- Update the QSS selector to `QPushButton, QToolButton { ... }` to ensure Qt matches `TBitBtn` regardless of how the LCL Qt widgetset classifies the button.

### Decision 4: Extend `UpdateGenericCardTheme` Selector
- In `overlayunit.pas:UpdateGenericCardTheme`, change:
  `SS := 'QCheckBox { color: ...; background-color: transparent; }';`
  to:
  `SS := 'QCheckBox, QRadioButton { color: ...; background-color: transparent; }';`
  so all cards utilizing generic card theming automatically cover radio buttons.

## Risks / Trade-offs

- **[Risk] Widget handle allocation at startup**: Controls created dynamically might not have handles allocated if the tab has never been displayed.
  → **Mitigation**: Ensure styling is applied both upon creation (when handle becomes available) and inside each tab sheet's `OnShow` theme update procedure (`UpdateVisualCardTheme`, `UpdatePerfCardTheme`, `UpdateExtrasCardTheme`).
