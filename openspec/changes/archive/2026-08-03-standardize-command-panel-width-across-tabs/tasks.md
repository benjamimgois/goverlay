# Tasks: Standardize Command Panel Width Across Tabs

## 1. Implement Helper & Navigation Anchoring

- [x] 1.1 In `overlayunit.pas`, declare and implement `procedure Tgoverlayform.UpdateCommandPanelRightAnchor(AButtonsVisible: Boolean);`.
- [x] 1.2 In `overlayunit.pas` (`optiscalerLabelClick`, `tweaksLabelClick`, `mangohudLabelClick`, `vkbasaltLabelClick`) and `games_tab.pas` (`ShowGamesTab` / `GameCardClick`), invoke `UpdateCommandPanelRightAnchor` with the appropriate visibility flag.

## 2. Automated GUI Unit Tests

- [x] 2.1 In `tests/gui/gui_test_cases.pas`, add unit test `TestCommandPanelRightMarginConsistency` verifying that `commandPanel.BorderSpacing.Right` is set to 153 on OptiScaler and EnvVars tabs, and 6 (anchored to `FPreviewBtn`) on MangoHud/vkBasalt tabs.
