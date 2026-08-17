# Tasks: OptiScaler Menu Scale Auto Option and Default

## 1. OptiScaler UI & Config Core Implementation

- [x] 1.1 Update `menuscaleComboBox` items in `optiscaler_tab.pas` to include `'auto'` as the first item (Index 0) and set `ItemIndex := 0` as default
- [x] 1.2 Update `LoadOptiScalerConfigCore` and `SaveOptiScalerConfigCore` in `overlay_config.pas` to handle `Scale=auto` (with `MenuScalePosition := 0`) and float values
- [x] 1.3 Update `LoadOptiScalerConfig` and `SaveOptiScalerConfig` in `optiscaler_tab.pas` to map combobox indices (0 for auto, 1..11 for 1.0..2.0)

## 2. Testing and Validation

- [x] 2.1 Update GUI tests in `tests/gui/gui_test_cases.pas` to verify `Scale=auto` and numeric scale persistence and loading
- [x] 2.2 Run full test suite (`make test` and `make test-logic`) and verify clean release build
