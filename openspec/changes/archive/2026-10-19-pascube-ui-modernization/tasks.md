# Tasks

## 1. UI Helpers and Styling Infrastructure

- [x] 1.1 Add card surface helper `DrawStyledCard` and status badge helper in `pascube_src/src/UnitPasCubeScreen.pas` and verify compilation with `lazbuild pascube_src/pascube.lpi`.
- [x] 1.2 Implement tier classification logic (`GetScoreTier`) returning gaming tier badge labels and accent colors based on score thresholds in `UnitPasCubeScreen.pas`.

## 2. Idle Menu Modernization

- [x] 2.1 Update `DrawMenuOverlay` in `UnitPasCubeScreen.pas` with the top hardware specifications summary badge, modernized title typography, and hero CTA buttons.
- [x] 2.2 Verify mouse hover detection and hitboxes (`IsStartButtonHovered`, `IsViewResultsButtonHovered`) align with the new button geometry.

## 3. Live Benchmark HUD & Execution Stepper

- [x] 3.1 Update `DrawBenchmarkOverlay` in `UnitPasCubeScreen.pas` with the horizontal phase stepper bar (`Warmup` → `CPU ST` → `CPU MT` → `GPU` → `RT`).
- [x] 3.2 Add the top-right floating live telemetry panel displaying real-time FPS, average FPS, CPU/GPU temperatures, and power draw in `DrawBenchmarkOverlay`.

## 4. Results Screen Redesign

- [x] 4.1 Redesign `DrawResultsOverlay` in `UnitPasCubeScreen.pas` with Hero Score card, luminous Tier badge, and dedicated Peak Telemetry summary card.
- [x] 4.2 Modernize the Score Trend visualization with clean bar geometry, run delta percentage badges, and improved axis contrast.
- [x] 4.3 Modernize the Hardware Comparison leaderboard cards with dual score bars (Raster + RT) and highlighted current-system styling.
- [x] 4.4 Update bottom action button bar (`Return to Menu`, `Submit results`, `Clear results`) and modal dialogs with the dark slate theme.

## 5. Build & Integration Verification

- [x] 5.1 Recompile PasCube with `lazbuild -B pascube_src/pascube.lpi` and verify 0 compilation errors.
- [x] 5.2 Copy the compiled binary to the project root (`cp pascube_src/pascube ./pascube`) and verify launch parameters with `./pascube --version`.

## Workflow follow-up

- Archive the change after implementation and user visual review are satisfied.
