# Tasks

## 1. Purge Dead Leaf Shapes, Images, and Controls (Grupo A)

- [x] 1.1 Remove `columShape` through `columShape5` from `overlayunit.lfm` and `overlayunit.pas`, eliminate all repetitive `columShape*.Visible := False` lines in `overlayunit.pas` and `mangohud_ui.pas`, and verify build succeeds.
- [x] 1.2 Remove legacy sidebar shapes (`mangohudShape`, `vkbasaltShape`, `optiscalerShape`, `tweaksShape`) from `overlayunit.lfm`, `overlayunit.pas`, and `sidebar_nav.pas`, and verify clean compilation.
- [x] 1.3 Remove orphaned preview images (`vImage`, `hImage`, `squareImage`, `roundImage`, `hudtoggleImage`) and orphaned controls (`activegpuLabel`, `gpudescEdit`) from `overlayunit.lfm` and `overlayunit.pas` (preserving `hudonoffComboBox`), and verify clean compilation.

## 2. Reparent Active Children and Purge Obsolete Containers (Grupo B)

- [x] 2.1 Reparent active controls in `overlayunit.lfm` from visual groupboxes directly to `visualTabSheet`, remove `orientationGroupBox`, `borderGroupBox`, `backgroundGroupBox`, `fontsGroupBox`, `positionGroupBox`, `columsGroupBox` from `overlayunit.lfm` and `overlayunit.pas`, remove unanchoring calls in `overlayunit.pas`, and verify form streaming.
- [x] 2.2 Reparent active metric controls in `overlayunit.lfm` from `gpuGroupBox` and `cpuGroupBox` directly to `metricsTabSheet`, remove `gpuGroupBox` and `cpuGroupBox` declarations and references, and verify clean compilation.
- [x] 2.3 Evaluate and clean up bottom bar container references, preserving `goverlaybarPanel` as host for `commandPanel` / `FPreviewBtn` and GUI test contract, and verify floating action dock functions without errors.

## 3. Verification and Regression Testing

- [x] 3.1 Run `make test-logic` and focused GUI integration tests (`TestMangoHudMetricsCompactToggles`, `TestMangoHudLoadColorPresets`, `TestPerformanceFiltersLayoutOnResize`), verifying all pass with 0 errors.
- [x] 3.2 Run full `make test-gui` validation pass before final archiving.

## Workflow follow-up

- Review proposal, design, and tasks with the user.
- Start the apply workflow when requested.
