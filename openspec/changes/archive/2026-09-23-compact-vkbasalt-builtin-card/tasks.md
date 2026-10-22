# Tasks

## 1. Compact Layout Implementation

- [x] 1.1 Update `vkbasalt_tab.pas`: set `BTIN_H = 148`, `Row0 := 38`, `Row1 := Row0 + 28 + 8` (74), and `Row2 := Row1 + 28 + 8` (110) in `ReflowVkBasaltTab`, verifying that all controls fit with 10px bottom margin
- [x] 1.2 Update `reshade_tab.pas`: set `BuiltinH := 148` in `ReflowReShadeTab` so `FVkReshadeCard` receives the reclaimed 47px

## 2. Test Updates and Verification

- [x] 2.1 Update `tests/gui/gui_test_cases.pas` in `TestVkBasaltPipelineCardVisibleAndBounds` to assert `goverlayform.FVkBuiltinCard.Height >= 148`
- [x] 2.2 Compile and run the GUI test suite (`./build_gui_tests.sh && ./run_gui_tests.sh` or equivalent project test runner) to verify layout integrity and zero regression
