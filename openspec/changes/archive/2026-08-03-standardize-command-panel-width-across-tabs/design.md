# Design: Standardize Command Panel Width Across Tabs

## Context

In GOverlay's bottom bar (`goverlaybarPanel`), `commandPanel` displays the full Steam launch command (`.../bgmod %command%`).
On tabs with bottom-bar buttons (MangoHud, vkBasalt, vkSumi, Games), `popupBitBtn` (30px) is right-anchored with an 85px margin, `FPreviewBtn` (28px) sits to its left with a 6px margin, and `commandPanel` anchors to the left of `FPreviewBtn` with a 6px margin. This positions `commandPanel`'s right edge at `goverlaybarPanel.Width - 153px`.

On OptiScaler and EnvVars tabs, `popupBitBtn` and `FPreviewBtn` are hidden (`Visible := False`). LCL anchor resolution bypasses invisible controls and anchors `commandPanel` directly to `goverlaybarPanel` with `BorderSpacing.Right := 6`, stretching `commandPanel` an extra ~147px across the bottom bar.

## Design Decisions

### 1. Helper `UpdateCommandPanelRightAnchor` in `Tgoverlayform`
Add procedure `UpdateCommandPanelRightAnchor(AButtonsVisible: Boolean)` in `overlayunit.pas`:
```pascal
procedure Tgoverlayform.UpdateCommandPanelRightAnchor(AButtonsVisible: Boolean);
begin
  if not Assigned(commandPanel) then Exit;
  if AButtonsVisible and Assigned(FPreviewBtn) then
  begin
    commandPanel.AnchorSideRight.Control := FPreviewBtn;
    commandPanel.AnchorSideRight.Side    := asrLeft;
    commandPanel.BorderSpacing.Right     := 6;
  end
  else if Assigned(goverlaybarPanel) then
  begin
    commandPanel.AnchorSideRight.Control := goverlaybarPanel;
    commandPanel.AnchorSideRight.Side    := asrRight;
    commandPanel.BorderSpacing.Right     := 153;
  end;
end;
```

### 2. Integration Points
Invoke `UpdateCommandPanelRightAnchor` in:
- `optiscalerLabelClick`: `UpdateCommandPanelRightAnchor(False)`
- `tweaksLabelClick`: `UpdateCommandPanelRightAnchor(False)`
- `mangohudLabelClick`: `UpdateCommandPanelRightAnchor(True)`
- `vkbasaltLabelClick`: `UpdateCommandPanelRightAnchor(True)`
- `GameCardClick` / `ShowGamesTab`: `UpdateCommandPanelRightAnchor(True)`

## Risk Analysis

- **Resizing / DPI scaling**: Using explicit 153px spacing matches the exact sum of fixed button dimensions and margins (`85 + 28 + 6 + 28 + 6 = 153px`).
- **Regression risk**: None; existing drawing logic in `commandPaintBox` renders relative to `commandPanel.ClientWidth`.

## Migration / Backwards Compatibility

No configuration file or schema changes required.
