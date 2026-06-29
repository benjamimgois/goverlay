## Context

GOverlay's dark theme interface benefits from cohesive modern styling. Standard Qt6 scrollbars are wide and have arrow buttons. We can inject a custom QSS string onto scrollable controls via `QWidget_setStyleSheet`.

## Goals / Non-Goals

**Goals:**
- Add `ApplyModernScrollBarStylesheet` helper in `themeunit.pas`.
- Apply narrow (8px), semitransparent rounded QSS styling to `TScrollBox`, `TMemo`, `TListBox`, `TListView` controls.

**Non-Goals:**
- Changing native OS desktop themes outside GOverlay.

## Decisions

### Decision 1: Centralized QSS application in `DoApplyTheme`
In `themeunit.pas`:
```pascal
procedure ApplyModernScrollBarStylesheet(AWinControl: TWinControl);
var
  SS: WideString;
begin
  if not AWinControl.HandleAllocated then Exit;
  SS := 'QScrollBar:vertical { border: none; background: transparent; width: 8px; margin: 0px; } ' +
        'QScrollBar::handle:vertical { background: rgba(255, 255, 255, 0.2); min-height: 20px; border-radius: 4px; } ' +
        'QScrollBar::handle:vertical:hover { background: rgba(255, 255, 255, 0.45); } ' +
        'QScrollBar::handle:vertical:pressed { background: rgba(255, 255, 255, 0.7); } ' +
        'QScrollBar::sub-line:vertical, QScrollBar::add-line:vertical { border: none; background: none; height: 0px; } ' +
        'QScrollBar::add-page:vertical, QScrollBar::sub-page:vertical { background: none; } ' +
        'QScrollBar:horizontal { border: none; background: transparent; height: 8px; margin: 0px; } ' +
        'QScrollBar::handle:horizontal { background: rgba(255, 255, 255, 0.2); min-width: 20px; border-radius: 4px; } ' +
        'QScrollBar::handle:horizontal:hover { background: rgba(255, 255, 255, 0.45); } ' +
        'QScrollBar::sub-line:horizontal, QScrollBar::add-line:horizontal { border: none; background: none; width: 0px; } ' +
        'QScrollBar::add-page:horizontal, QScrollBar::sub-page:horizontal { background: none; }';
  QWidget_setStyleSheet(TQtWidget(AWinControl.Handle).Widget, @SS);
end;
```
When checking control types in `DoApplyTheme`:
- For `TScrollBox`, `TMemo`, `TListBox`, `TListView`, call `ApplyModernScrollBarStylesheet`.

## Risks / Trade-offs

- None identified.
