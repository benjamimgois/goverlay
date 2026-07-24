## 1. vkBasalt & vkSumi Round-Trip Tests

- [x] 1.1 In `tests/gui/gui_test_cases.pas`, add `TestVkBasaltRoundTrip` testing `LoadVkBasaltConfig` and UI control assertions.
- [x] 1.2 In `tests/gui/gui_test_cases.pas`, add `TestVkSumiRoundTrip` testing `LoadVkSumiConfig` and trackbar assertions.

## 2. Tweaks Tab Round-Trip Tests

- [x] 2.1 In `tests/gui/gui_test_cases.pas`, add `NavigateTweaksTab` and `TestTweaksTabRoundTrip` testing Tweaks tab controls saving and reloading via `LoadTweaksConfig`.

## 3. Verification

- [x] 3.1 Run `make test` to verify all new GUI round-trip tests pass cleanly.
