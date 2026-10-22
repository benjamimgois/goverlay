## 1. UI Event Handlers Cleanup

- [x] 1.1 Remove `'cas'`, `'fxaa'`, `'smaa'`, `'dls'` insertion/deletion logic from `casTrackBarChange`, `fxaaTrackBarChange`, `smaaTrackBarChange`, and `dlsTrackBarChange` in `overlayunit.pas`

## 2. Configuration Serializer Defensive Filtering

- [x] 2.1 Add `IsVkBasaltBuiltInEffect` filter in `overlay_config.pas` and skip built-in effects when iterating `Settings.ReshadeEffects` in `SaveVkBasaltConfig`

## 3. Testing and Verification

- [x] 3.1 Update unit/GUI test assertions in `tests/gui/gui_test_cases.pas` to verify single-instance `effects = cas` and absence of `cas = .../reshade-shaders/cas`
- [x] 3.2 Run test suite (`make test-gui` and `make test-logic`) to verify fix and absence of regressions
