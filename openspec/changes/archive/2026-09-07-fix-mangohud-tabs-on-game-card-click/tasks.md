## 1. Refactor GameCardClick Navigation

- [x] 1.1 In `games_tab.pas`, refactor `TGamesTabHelper.GameCardClick` to replace the manual tab-switching block with `mangohudLabelClick(nil)` followed by `FLaunchCommand := GetLaunchCommand; if Assigned(commandPaintBox) then commandPaintBox.Invalidate;`, and verify compilation with `lazbuild`.

## 2. Automated Regression Testing

- [x] 2.1 Add a GUI test in `tests/gui/gui_test_cases.pas` that visits OptiScaler/vkBasalt, navigates back to Games, clicks a game card, and asserts that all 5 MangoHud tabs (`presetTabSheet`, `visualTabSheet`, `performanceTabSheet`, `metricsTabSheet`, `extrasTabSheet`) have `TabVisible = True` and `goverlayPageControl.ShowTabs = True`.
- [x] 2.2 Run the GUI test suite and verify that all test assertions pass.
