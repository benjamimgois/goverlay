# Tasks

## 1. Shader Filtering and Deduplication

- [x] 1.1 Expose `IsVkBasaltBuiltInEffect` in `overlay_config.pas` interface and update `ListFilesToListBox` in `overlayunit.pas` to track seen effect base names case-insensitively and exclude all effects matching `IsVkBasaltBuiltInEffect` (including `fxaa`, `smaa`, and `lut`)
- [x] 1.2 Update `ListFilesToListBox` calls in `overlayunit.pas` and `vkbasalt_tab.pas` to pass `['.fx', '.glsl']` instead of `['.fx', '.fxh', '.h', '.glsl']`

## 2. Test Verification

- [x] 2.1 Update automated test in `tests/gui/gui_test_cases.pas` verifying that `.fxh` files are skipped, duplicate effect names are deduplicated to a single entry, and built-in FXAA, SMAA, and LUT are excluded from `aveffectsListbox`
- [x] 2.2 Run `make test-gui` and `make test-logic` to verify that all tests pass without errors or regressions
