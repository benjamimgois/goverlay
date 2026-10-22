# Proposal

## Why

Upstream `mangoplot` requires external Python (`matplotlib`/`numpy`) dependencies, rejects any MangoHud benchmark CSV with fewer than 10,000 samples (causing 60-second runs at default 100ms logging interval to fail with `"simulation isn't long enough for precise statistics"`), and discards frames above 1,000 FPS (breaking benchmarks on lightweight scenes such as `pascube`). Furthermore, MangoHud benchmark CSVs are currently written directly into the root `~/.local/share/goverlay` directory rather than organized per game inside `~/.local/share/goverlay/logs/<game>/`. Building a native **PasPlot** benchmark viewer inside GOverlay (matching the naming style of `PasCube`) eliminates external dependencies, supports arbitrary benchmark durations and frame rates, organizes benchmark logs cleanly per game, and allows users to inspect and compare runs directly from the UI.

## What Changes

- **Per-Game Benchmark Log Directory (`~/.local/share/goverlay/logs/<game>/`)**:
  - Change the default MangoHud `output_folder` (`logfolderEdit`) from `~/.local/share/goverlay` to `~/.local/share/goverlay/logs/<game>/` when a game profile is active, or `~/.local/share/goverlay/logs/` in Global mode (with automatic upgrade of legacy default `~/.local/share/goverlay` paths and `ForceDirectories` creation when saving/loading configs).
  - Automatically organize loose `<app>_YYYY-MM-DD_HH-MM-SS.csv` (and companion `_summary.csv`) benchmark files found in `~/.local/share/goverlay/` or `~/.local/share/goverlay/logs/` into `~/.local/share/goverlay/logs/<app>/` subdirectories.
- **PasPlot Button in MangoHud Extras (`Logging` Card)**:
  - Add a **PasPlot** button inside `FExtLogCard` (`mangohud_ui.pas`) next to the `Logging toggle` shortcut button (`FLoggingCaptureBtn`), styled consistently with GOverlay's active theme (Dark/Light).
- **Native PasPlot Benchmark Viewer Window (`pasplot_form.pas`)**:
  - Create a dedicated native LCL/Qt6 form (`TpasplotForm` / `TgplotForm`) launched via the **PasPlot** button (pre-selecting the currently active game if available) or via `--pasplot` (or `--gplot`) CLI flag.
  - Parse MangoHud benchmark CSV files (extracting line 2 system hardware metadata and line 4+ time-series telemetry columns while ignoring `_summary.csv` companion files in the run selector) without arbitrary sample-count minimums or FPS ceilings.
  - Support single-run and multi-run comparative visualization across three views:
    1. **FPS & Frametime Timeline**: Interactive time-series line chart (`fps` and `frametime` over `elapsed` time).
    2. **Summary Comparison**: Bar chart and comparative statistics table showing Average FPS, 1% Low FPS, 0.1% Low FPS, Min/Max FPS, Average Frametime (ms), and percentage deltas (`Δ %`) across selected runs.
    3. **Hardware Telemetry**: Time-series and summary comparison of GPU/CPU Load (`%`), Temperature (`°C`), Power (`W`), and VRAM/RAM usage.
  - Provide actions to Refresh runs, Open the game's log folder, Delete selected runs (cleaning up both `.csv` and `_summary.csv`), and Export the active chart/comparison to a `.png` image.

## Capabilities

### New Capabilities
- `gplot-benchmark-viewer`: Native MangoHud CSV benchmark log parser, auto-organizer (`~/.local/share/goverlay/logs/<game>/`), interactive time-series/comparative chart viewer (`PasPlot` / `pasplot_form.pas`), PNG exporter, and Extras tab UI integration.

### Modified Capabilities
- `centralized-tools-logging`: Extend centralized `~/.local/share/goverlay/logs/<GameDirName>/` directory management to cover MangoHud CSV benchmark `output_folder` defaults and automatic migration/organization of loose MangoHud benchmark CSV files.

## Impact

- **Affected Code**:
  - `pasplot_form.pas` (new unit): Native LCL/Qt6 benchmark analyzer window (`PasPlot`), CSV parser, statistics engine (Avg, 1% Low, 0.1% Low, frametime, hardware telemetry), custom `TPaintBox` chart renderer, and PNG export.
  - `mangohud_ui.pas`: Add `FGplotBtn` (`Caption := 'PasPlot'`) inside `FExtLogCard`, position it in `ReflowExtrasTab`, apply theme styling, and update default `logfolderEdit.Text` to use `GetGameLogDir(FActiveGameName)`.
  - `overlayunit.pas` & `overlay_config.pas`: Update default `logfolderEdit` initialization, automatic legacy `output_folder` upgrade on game switch/load, `ForceDirectories` on `output_folder` save, and handler to open `PasPlot`.
  - `goverlay.lpr`: Register `pasplot_form` unit and optional `--pasplot` / `--gplot` CLI launch parameter.
  - `tests/gui/gui_test_cases.pas`: Add unit and GUI tests covering CSV parsing, statistics calculation (including <10,000 samples and >1,000 FPS), log directory auto-organization, and `FGplotBtn` / `TpasplotForm` instantiation.
- **Dependencies**: Zero new external runtime dependencies (uses native FPC/LCL `TCanvas`/`TBitmap`/`TPortableNetworkGraphic`).
