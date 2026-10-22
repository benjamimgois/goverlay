## 1. Config Keys and Serialization Logic

- [x] 1.1 Add `OPTI_INI_SECTION_LOG` and `OPTI_KEY_LOG_LEVEL` in `configkeys.pas` and verify compilation
- [x] 1.2 Add `LogLevelItemIndex: Integer` to `TOptiScalerSettings` in `overlay_config.pas`
- [x] 1.3 Update `LoadOptiScalerConfig` in `overlay_config.pas` to parse `[Log] LogLevel` (defaulting to 2 when auto/missing/invalid) and resolve `LoadAsiPlugins=auto` (and missing) to `True`
- [x] 1.4 Update `SaveOptiScalerConfigCore` in `overlay_config.pas` to write `LogLevel=<N>` under `[Log]` in `OptiScaler.ini` and verify with logic tests

## 2. UI Controls and Layout

- [x] 2.1 Declare `loglevelLabel` and `loglevelComboBox` in `Tgoverlayform` (`overlayunit.pas`) and implement `loglevelComboBoxChange` with `StartAutoSaveTimer`
- [x] 2.2 Instantiate `loglevelLabel` and `loglevelComboBox` with items `0 - Trace` through `4 - Error` (default index 2) and performance warning tooltip in `optiscaler_tab.pas`
- [x] 2.3 Reflow `loglevelLabel` and `loglevelComboBox` below `menuscaleComboBox` and update `MinOptH` to 365 in `ReflowOptiScalerTabNew`
- [x] 2.4 Connect `loglevelComboBox` in `LoadOptiScalerConfig` and `SaveOptiScalerConfig` in `optiscaler_tab.pas` with event suppression during loading

## 3. Verification and Automated Testing

- [x] 3.1 Add GUI tests in `tests/gui/gui_test_cases.pas` validating LogLevel items, tooltip, auto-save trigger, `OptiScaler.ini` persistence, and OptiPatcher default enabled behavior
- [x] 3.2 Run `make test-logic`, `make test-gui`, and `lazbuild goverlay.lpi --bm=Release` to verify 100% test pass rate and clean compilation
