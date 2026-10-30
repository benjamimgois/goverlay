# Tasks

## 1. Purge Performance Tab Legacy Containers and Controls

- [x] 1.1 Remove dead image `fpstoggleImage` and orphaned controls (`fpslimCheckGroup`, `offsetSpinEdit`, `offsetLabel`, `fpslimLabel`) from `overlayunit.lfm` and `overlayunit.pas`.
- [x] 1.2 Reparent active controls in `performanceTabSheet` (including `filterRadioGroup`, `vulkanImage`, `openglImage`, etc.) from `fpslimiterGroupBox`, `vsyncGroupBox`, `filtersGroupBox`, and `fpsGroupBox` directly to `performanceTabSheet` with `Anchors = []` and `Visible = False`, remove the 4 groupbox declarations and unanchoring calls in `overlayunit.pas` and `mangohud_ui.pas`, and verify build succeeds.
- [x] 1.3 Run focused performance tests (`TestMangoHudPerformanceCompactToggles`, `TestPerformanceFiltersLayoutOnResize`, `TestMangoHudFrameTimingDetailed`) and verify 0 errors.

## 2. Purge Extras Tab Legacy Containers and Controls

- [x] 2.1 Remove dead images (`Image2`, `logtoggleImage`, `sysinfoImage`) from `overlayunit.lfm` and `overlayunit.pas`.
- [x] 2.2 Reparent active controls in `extrasTabSheet` from `loggingGroupBox` and `systemGroupBox` directly to `extrasTabSheet` with `Anchors = []` and `Visible = False`, remove the 2 groupbox declarations and unanchoring calls in `overlayunit.pas` and `mangohud_ui.pas`, and verify build succeeds.
- [x] 2.3 Run focused extras tests (`TestMangoHudExtrasCompactToggles`, `TestGplotLogDirectoryAndAutoOrganization`) and verify 0 errors.

## 3. Full Verification and Archiving

- [x] 3.1 Run `make test-logic` to verify non-GUI subsystems remain regression-free.
- [x] 3.2 Run full `make test-gui` validation pass before final archiving.

## Workflow follow-up

- Review proposal, design, and tasks with the user.
- Start the apply workflow when requested.
