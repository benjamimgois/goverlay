## Why

The GUI test suite currently lacks round-trip save/load test coverage for vkBasalt and vkSumi, and has zero test coverage for the Tweaks tab. Adding comprehensive round-trip tests for these three areas will ensure that saving, loading, and tab-switching persistence remain fully functional across all GOverlay features.

## What Changes

- Add full round-trip save/load test procedure `TestVkBasaltRoundTrip` in `tests/gui/gui_test_cases.pas` to test vkBasalt settings reloading.
- Add full round-trip save/load test procedure `TestVkSumiRoundTrip` in `tests/gui/gui_test_cases.pas` to test vkSumi trackbar reloading.
- Add navigation and round-trip save/load test procedure `TestTweaksTabRoundTrip` in `tests/gui/gui_test_cases.pas` to test Tweaks tab UI controls.

## Capabilities

### New Capabilities
- `add-vkbasalt-vksumi-tweaks-gui-tests`: Expands the GUI test suite to cover vkBasalt, vkSumi, and Tweaks tab configurations with full bidirectional round-trip tests (Save -> Load -> Assert UI state).

### Modified Capabilities

## Impact

- `tests/gui/gui_test_cases.pas`: New test procedures added for vkBasalt, vkSumi, and Tweaks tabs.
