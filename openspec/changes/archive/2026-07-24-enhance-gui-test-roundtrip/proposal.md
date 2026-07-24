## Why

The GUI test suite previously tested configuration saving in a write-only direction (UI -> file string assertion), omitting the reload phase (file -> UI control verification). As a result, bugs where options save to file but revert on reload/tab switch were not caught automatically by `make test`.

Enhancing the test suite to perform bidirectional round-trip testing (Save -> Reload -> Assert UI state) and tab-switching persistence checks will ensure regression detection for all GOverlay overlays.

## What Changes

- Update GUI test cases in `tests/gui/gui_test_cases.pas` to include `Load...Config` calls and UI control assertions across MangoHud, OptiScaler, and vkBasalt test procedures.
- Add tab-switching persistence tests that simulate navigating away to another overlay tab and back, verifying no UI controls reset unexpectedly.

## Capabilities

### New Capabilities
- `enhance-gui-test-roundtrip`: Expands the GUI test suite to verify full bidirectional round-trip saving and loading (File -> UI control assertions) and tab-switching persistence across all overlay configurations.

### Modified Capabilities

## Impact

- `tests/gui/gui_test_cases.pas`: Enhanced test cases with round-trip load calls and UI control assertions.
