# Tasks

## 1. OptiScaler Force Reflex Synchronization

- [x] 1.1 Update `LoadOptiScalerConfig` in `overlay_config.pas` to treat `force_reflex=0` and missing keys as unchecked (`ForceReflexChecked := False`), and `1` or `2` as checked, and verify with unit tests.
- [x] 1.2 Update `SaveOptiScalerConfigCore` in `overlay_config.pas` to serialize `force_reflex=0` when unchecked to prevent ghost re-activation from seeded templates.
- [x] 1.3 Add test cases in `tests/gui/gui_test_cases.pas` and `tests/logic/logic_test_cases.pas` for `force_reflex=0` unforced semantics and verify with `make test-logic`.

## 2. Resilient MangoHud Color Parsing and Error Isolation

- [x] 2.1 Refactor `HexToColor` in `mangohud_ui.pas` to sanitize hex values (trim, strip `#`, expand 3-char shorthand) and safely parse using `TryStrToInt` with fallback colors.
- [x] 2.2 Wrap per-line parsing in `LoadMangoHudConfig` inside `try ... except` handlers in `mangohud_ui.pas` so that malformed entries do not abort loading remaining settings.
- [x] 2.3 Add test cases in `tests/logic/logic_test_cases.pas` verifying `#`-prefixed colors and malformed lines parse safely, and verify with `make test-logic`.

## 3. Verification

- [x] 3.1 Run `make test-logic` and verify all tests pass without regressions.
