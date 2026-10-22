## 1. Implement Targeted In-Place Card Badge Updating

- [x] 1.1 Implement `UpdateGameCardBadge(const AGameName: string)` in `TGamesTabHelper` in `games_tab.pas` to locate the target game's card panel and update its badge icon and tooltip in-place without rebuilding unaffected cards.
- [x] 1.2 Update `gamesLabelClick` in `overlayunit.pas` to record `LastGameName := FActiveGameName;` and call `UpdateGameCardBadge(LastGameName)` instead of the full library `RefreshGameCards`.

## 2. Test Updates and Regression Verification

- [x] 2.1 Add GUI tests in `tests/gui/gui_test_cases.pas` verifying that returning from game mode via `gamesLabelClick` keeps existing card panel references alive and updates the edited game's badge correctly.
- [x] 2.2 Run the full GUI test suite (`make test-gui`) and logic tests (`make test-logic`) to ensure all tests pass with zero failures.
