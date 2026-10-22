## Why

When clicking a game card on the Games tab to configure a game, GOverlay navigates to the MangoHud configuration view. However, if the user has previously visited other sidebar sections (such as Post processing / vkBasalt or Upscalers / OptiScaler), those handlers explicitly hide the MangoHud tab sheets by setting `TabVisible := False`.

Because `GameCardClick` in `games_tab.pas` duplicated only a subset of the tab-switching logic and did not restore `TabVisible := True` on `presetTabSheet`, `visualTabSheet`, `performanceTabSheet`, `metricsTabSheet`, and `extrasTabSheet`, the Qt/LCL `QTabBar` has zero visible tabs to render. As a result, the tab bar at the top of the screen disappears entirely, forcing the user to click another menu item and return to MangoHud to recover the tabs.

Delegating tab activation directly to `mangohudLabelClick(nil)` eliminates code duplication, restores all MangoHud tab visibilities, and guarantees consistent UI state.

## What Changes

- Update `TGamesTabHelper.GameCardClick` in `games_tab.pas` to delegate MangoHud tab activation and docking configuration to `FForm.mangohudLabelClick(nil)` instead of using an incomplete manual tab switch.
- Ensure all MangoHud tab sheets (`presetTabSheet`, `visualTabSheet`, `performanceTabSheet`, `metricsTabSheet`, `extrasTabSheet`) are properly visible, while non-MangoHud tabs are hidden.
- Add an automated GUI regression test in `tests/gui/gui_test_cases.pas` that navigates to OptiScaler/vkBasalt, returns to Games, clicks a game card, and asserts that all MangoHud tabs have `TabVisible = True` and the tab bar is visible.

## Capabilities

### Modified Capabilities
- `per-game-launch-options`: Extend game card selection requirements to guarantee that MangoHud configuration tabs are visible in the tab bar after selecting a game card, regardless of prior navigation history.

## Impact

- Modified files:
  - `games_tab.pas`: `GameCardClick` procedure.
  - `tests/gui/gui_test_cases.pas`: Regression test for tab visibility after game card selection.
- Dependencies & APIs: No external dependency changes, no breaking changes.
