# Proposal: Purge MangoHud Legacy Containers and Dead Controls

## Why

Following the successful cleanup of dead leaf shapes and obsolete groupboxes in the Visual and Metrics tabs, GOverlay's MangoHud subsystem still contains legacy UI containers (`TGroupBox`) and orphaned controls in the `Performance` and `Extras` tabs within `overlayunit.lfm` and `overlayunit.pas`.

These legacy containers and embedded decorative images (hexadecimal bitmap dumps in the `.lfm`) are completely hidden at runtime, since modern code-driven cards and toggle switches in `mangohud_ui.pas` handle all active visual elements. Purging the remaining legacy containers and orphaned controls in `performanceTabSheet` and `extrasTabSheet` will leave 100% of the MangoHud tab structure modern, clean, and free of redundant LCL streaming definitions.

## What Changes

- **Purge Obsolete Decorative Images (Performance & Extras)**:
  - Remove `fpstoggleImage`, `vulkanImage`, `openglImage` from `performanceTabSheet`.
  - Remove `Image2`, `logtoggleImage`, `sysinfoImage` from `extrasTabSheet`.
  - Eliminate hundreds of lines of base16/hexadecimal image data from `overlayunit.lfm`.

- **Purge Dead Orphaned Controls**:
  - Remove `fpslimCheckGroup`, `filterRadioGroup`, `offsetSpinEdit`, `offsetLabel`, `fpslimLabel` which are completely dead and superseded by modern card widgets.

- **Reparent Active Controls and Purge Obsolete GroupBoxes**:
  - Reparent active controls from `fpslimiterGroupBox`, `vsyncGroupBox`, `filtersGroupBox`, `fpsGroupBox` directly to `performanceTabSheet` with `Anchors = []` and `Visible = False`.
  - Reparent active controls from `loggingGroupBox` and `systemGroupBox` directly to `extrasTabSheet` with `Anchors = []` and `Visible = False`.
  - Remove `fpslimiterGroupBox`, `vsyncGroupBox`, `filtersGroupBox`, `fpsGroupBox`, `loggingGroupBox`, and `systemGroupBox` from `overlayunit.lfm` and `overlayunit.pas`.
  - Clean up obsolete `UnanchorControl` calls and `Visible := False` assignments in `overlayunit.pas` and `mangohud_ui.pas`.

- **Preserve Functional State and Serialization (Non-goals)**:
  - Do NOT alter any state-holding controls (e.g. `fpsCheckBox`, `frametimegraphCheckBox`, `distroinfoCheckBox`, `wineCheckBox`, etc.) read/written by `SaveMangoHudConfig` and `LoadMangoHudConfig`.
  - Do NOT change any configuration file serialization logic or test assertions.

## Capabilities

### New Capabilities
None.

### Modified Capabilities
None. This change is an internal UI cleanup and form streaming refactoring with `skip_specs: true`.

## Impact

- `overlayunit.lfm`: Significant reduction in component count and removal of obsolete embedded bitmaps.
- `overlayunit.pas`: Removal of obsolete container field declarations and redundant unanchoring logic.
- `mangohud_ui.pas`: Removal of dead groupbox visibility hiding.
- Test suites: Unchanged behavior across `make test-logic` and focused GUI integration tests.
