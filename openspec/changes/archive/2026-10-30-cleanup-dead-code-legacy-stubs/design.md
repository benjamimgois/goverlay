# Design: Cleanup Dead Code and Legacy Stubs

## Architectural Context
Previous changes purged legacy groupboxes and restored controls directly into modern card designs. The Pascal source code still includes unused declarations, dead branches for `TGroupBox`, and no-op procedures that were kept as transition stubs.

## Detailed Design Decisions

### 1. ReflowOptiScalerTab Elimination
- In `overlayunit.pas`:
  - Remove declaration `procedure ReflowOptiScalerTab(AContentW: Integer);`
  - Remove implementation body of `procedure Tgoverlayform.ReflowOptiScalerTab`
  - In `FormShow`, `optiscalertabsheetShow`, and `sidebar_nav.pas`, remove calls to `ReflowOptiScalerTab(InitW)` and `ReflowOptiScalerTab(ContentW)`.
  - Ensure `ReflowOptiScalerTabNew` remains the sole, active reflow entrypoint.

### 2. TGroupBox Dead Code Purge
- In `overlayunit.pas`:
  - Remove `procedure StyleGroupBoxNavy(GB: TGroupBox);` declaration and implementation.
  - In `ClearSearchHighlights`, remove `else if TabSheet.Controls[j] is TGroupBox` and container checks.
  - In `SearchEditChange`, remove `else if AControl is TGroupBox` block.
  - In `AddNavyBgToTab` or card styling loops, clean any remaining `is TGroupBox` branches.
- In `optiscaler_tab.pas`:
  - Remove unused nested procedure `ReparentGB`.
- In `themeunit.pas`:
  - Remove `else if ctrl is TGroupBox` branch.
- In `uihelpers.pas`:
  - Remove `is TGroupBox` styling branches from `ApplyModernTypography` and `ApplyModernSpacing`.
- In `mangohud_ui.pas`:
  - Remove `if Card.Controls[j] is TGroupBox` dead styling loops.

### 3. Obsolete Button & Stub Elimination
- In `overlayunit.pas`:
  - Remove `procedure UpdateGeSpeedButtonState;` and all calls to it across tab switch methods (`vkbasaltLabelClick`, `mangohudLabelClick`, `tweaksLabelClick`, etc.).
  - Remove `procedure geSpeedButtonClick(Sender: TObject);`.
  - Remove `geSpeedButton` and `geLabel` from `overlayunit.lfm` and `overlayunit.pas` if completely disconnected, or keep purely as hidden placeholders if anchor dependencies in `goverlaybarPanel` require it.

## Risks & Mitigations
- **Risk:** Any lingering caller to `ReflowOptiScalerTab` causing compilation errors.
  - **Mitigation:** Comprehensive grep for all usages and removal before building.
- **Risk:** Unanchoring issues in `goverlaybarPanel` if `geSpeedButton` is removed.
  - **Mitigation:** Inspect `overlayunit.lfm` for controls anchored to `geSpeedButton` (e.g. `notificationLabel`) and re-anchor them cleanly to `goverlaybarPanel` before removing `geSpeedButton`.
