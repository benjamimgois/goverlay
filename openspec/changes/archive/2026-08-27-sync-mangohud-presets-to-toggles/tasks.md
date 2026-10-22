## 1. Preset Synchronization in Preset Cards and Handlers

- [x] 1.1 Hook `SyncAllToggles` in `TMangoHudUiHelper.PresetCardClick` after applying layout preset actions.
- [x] 1.2 Hook `SyncAllToggles` in `fullBitBtnClick`, `basicBitBtnClick`, `basichorizontalBitBtnClick`, and `fpsonlyBitBtnClick`.
- [x] 1.3 Hook `SyncAllToggles` in `SetAllCheckBoxesToTrue` and `SetAllCheckBoxesToFalse`.

## 2. Sub-Tab OnShow Synchronization

- [x] 2.1 Hook `SyncVisualToggles` in `visualTabSheetShow`.
- [x] 2.2 Hook `SyncPerformanceToggles` in `performanceTabSheetShow`.
- [x] 2.3 Hook `SyncMetricsToggles` in `metricsTabSheetShow`.
- [x] 2.4 Hook `SyncExtrasToggles` in `extrasTabSheetShow` (or create `extrasTabSheetShow`).

## 3. Automated Testing & Verification

- [x] 3.1 Add GUI automated tests in `tests/gui/gui_test_cases.pas` verifying toggle states when clicking Full, Basic, Basic Horizontal, and FPS Only presets.
- [x] 3.2 Run full GUI test suite `./tests/gui/gui_tests --all` and build release binary `lazbuild --ws=qt6 goverlay.lpi`.
