# Tasks: Unified Alphabetical Sorting for Game Cards

## 1. Data Structures and Discovery Helpers

- [x] 1.1 Define `TGameKind` and `TGameDiscoveryItem` records in [`games_tab.pas`](file:///mnt/NVME/Software/goverlay/games_tab.pas) and verify compilation
- [x] 1.2 Implement discovery procedures to scan Steam manifests and non-Steam folders into a unified dynamic array without instantiating UI controls, and verify compilation
- [x] 1.3 Implement a deterministic sorting procedure using `AnsiCompareText` (case-insensitive, symbols/numbers first, strict article handling) with stable secondary tie-breaking, and verify compilation

## 2. Card Construction and Integration

- [x] 2.1 Update [`TGamesTabHelper.LoadSteamGames`](file:///mnt/NVME/Software/goverlay/games_tab.pas) to execute the two-phase flow (aggregate discovery -> sort -> instantiate cards in sorted order) and verify compilation
- [x] 2.2 Ensure asynchronous cover download queues (`TCoverDownloadThread` and `TNonSteamCoverThread`) record correct card indices and parent references for both platforms, and verify compilation
- [x] 2.3 Ensure `NoGamesLabel` triggers only when total combined discovered games count is zero, allowing non-Steam libraries to display even if Steam has no games

## 3. Automated Tests and Verification

- [x] 3.1 Add regression test cases in [`tests/gui/gui_test_cases.pas`](file:///mnt/NVME/Software/goverlay/tests/gui/gui_test_cases.pas) verifying alphabetical card order for mixed Steam and non-Steam fixtures
- [x] 3.2 Run `make test-logic` and `make test-gui` to verify that all existing and new tests pass without regressions
