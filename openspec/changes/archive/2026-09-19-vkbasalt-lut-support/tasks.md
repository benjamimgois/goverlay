# Tasks

## 1. Backend Serialization and Model Support

- [x] 1.1 Update `TVkBasaltSettings` record in `overlay_config.pas` to include `LutEnabled: Boolean` and `LutFile: string`, and verify project compiles with `lazbuild --ws=qt6 tests/logic/logic_tests.lpi`
- [x] 1.2 Update `IsVkBasaltBuiltInEffect` in `overlay_config.pas` to return `True` for `'lut'`, preventing it from being treated as a ReShade `.fx` file
- [x] 1.3 Update `SaveVkBasaltConfig` in `overlay_config.pas` to write `lutFile = "<path>"` (with quotes) when `LutFile` is specified and ensure `lut` is serialized in `effects = ...`
- [x] 1.4 Update `LoadVkBasaltConfig` in `overlay_config.pas` to parse `lutFile` and populate `Settings.LutFile` and `Settings.LutEnabled` without adding `lut` to `acteffectsListBox`
- [x] 1.5 Add logic tests in `tests/logic/logic_test_cases.pas` verifying serialization and loading round-trip for `lut` and `lutFile`, and verify test suite passes with `./tests/logic/logic_tests --all`

## 2. Home Tab Libraries Status

- [x] 2.1 Update `MOD_NAMES` in `home_tab.pas` to include `'ReShade'` (expanding module count from 7 to 8) and adjust `FHomeModDots`, `FHomeModVerLbls`, and card height calculation
- [x] 2.2 Update `RefreshHomeModuleStatus` in `home_tab.pas` to check `IsReShadeInstalled` and display `6.4 (Add-on Edition)` or `not found` with the appropriate status dot color

## 3. UI Controls in Built-in Effects Card

- [x] 3.1 Create `FVkLutIcon`, `FVkLutLabel`, `FVkLutPathEdit`, `FVkLutBrowseBtn`, and `FVkLutClearBtn` in `TVkBasaltTabHelper.InitVkBasaltTab` within `vkbasalt_tab.pas`
- [x] 3.2 Implement Browse click handler with `TOpenDialog` (`*.cube;*.png`) that updates path, automatically calls `AddEffectToPipeline('lut')`, and triggers auto-save
- [x] 3.3 Implement Clear click handler (`✕`) that clears path, calls `RemoveEffectFromPipeline('lut')`, and triggers auto-save
- [x] 3.4 Update `DisablePipelineEffect` and `VkRestoreBtnClick` in `vkbasalt_tab.pas` to clear the LUT path edit and remove `lut` from pipeline
- [x] 3.5 Update pipeline chip painting and label casing in `VkPipelineCardPaint` in `vkbasalt_tab.pas` so that `'lut'` renders cleanly as `'LUT'`

## 4. Tab Layout Reflow & Re-anchoring

- [x] 4.1 Update `ReflowReShadeTab` in `reshade_tab.pas` for `rmVkBasalt` to set `FStatusCard.Visible := False`, expand `BuiltinH` to ~195px, and anchor `FVkPipelineCard` at the bottom
- [x] 4.2 Update `ReflowVkBasaltTab` in `vkbasalt_tab.pas` to position the Color LUT controls on Row 2 of `FVkBuiltinCard`
- [x] 4.3 Ensure `FStatusCard.Visible := True` when switching method to `rmReshade` or `rmNone` in `reshade_tab.pas`

## 5. Verification & Testing

- [x] 5.1 Update GUI test assertions in `tests/gui/gui_test_cases.pas` (such as `TestVkBasaltPipelineCardVisibleAndBounds`) to verify `FStatusCard.Visible = False` in `rmVkBasalt` and `PipelineCard` is anchored at the bottom
- [x] 5.2 Build full application with `lazbuild --ws=qt6 goverlay.lpr` and verify zero compilation errors
- [x] 5.3 Run full test suites (`logic_tests` and `gui_tests`) to verify all automated tests pass without regressions
