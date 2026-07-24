## Context

The GUI test suite previously lacked tests for the Tweaks tab and had only partial one-way tests for vkBasalt and vkSumi without reload verification (`LoadVkBasaltConfig` / `LoadVkSumiConfig`).

## Goals / Non-Goals

**Goals:**
- Implement `TestVkBasaltRoundTrip` in `tests/gui/gui_test_cases.pas` to test vkBasalt UI controls saving and reloading via `LoadVkBasaltConfig`.
- Implement `TestVkSumiRoundTrip` in `tests/gui/gui_test_cases.pas` to test vkSumi trackbars saving and reloading via `LoadVkSumiConfig`.
- Implement `TestTweaksTabRoundTrip` in `tests/gui/gui_test_cases.pas` to test Tweaks tab navigation and UI controls saving/reloading via `LoadTweaksConfig`.

**Non-Goals:**
- Modifying production app source code unless test assertions reveal underlying bugs.

## Decisions

### Decision 1: Test Procedures Structure
1. `TestVkBasaltRoundTrip`: Set `casTrackBar`, `fxaaTrackBar`, `smaaTrackBar`, etc., call `saveBitBtn.OnClick`, call `LoadVkBasaltConfig`, assert UI trackbars and controls.
2. `TestVkSumiRoundTrip`: Set `FVsTrackbars` positions, call `saveBitBtn.OnClick`, call `LoadVkSumiConfig`, assert trackbar positions.
3. `TestTweaksTabRoundTrip`: Click `tweaksLabel`, set tweak checkboxes, call `saveBitBtn.OnClick`, call `LoadTweaksConfig`, assert checkbox states.
