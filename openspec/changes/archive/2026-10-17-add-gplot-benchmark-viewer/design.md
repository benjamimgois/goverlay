# Design

## Context

See `proposal.md` for motivation. Currently, MangoHud's `output_folder` in `mangohud_ui.pas` (`ResetMangoHudDefaults`) and `overlayunit.pas` (`FormCreate`) defaults to `GetGOverlayDataDir()` (`~/.local/share/goverlay`), whereas GOverlay already centralizes all other tool logs under `~/.local/share/goverlay/logs/<GameDirName>/` via `GetGameLogDir(FActiveGameName)` (`overlayunit.pas:10310`). Furthermore, users attempting to analyze MangoHud CSV logs with upstream `mangoplot` encounter hard failures on runs under 10,000 samples or framerates above 1,000 FPS.

## Goals / Non-Goals

**Goals:**
- Unify MangoHud CSV benchmark output directories with `GetGameLogDir(FActiveGameName)` (`~/.local/share/goverlay/logs/<GameDirName>/` for per-game profiles and `~/.local/share/goverlay/logs/` for Global mode), ensuring directories exist on disk before MangoHud runs.
- Automatically organize loose `<app>_YYYY-MM-DD_HH-MM-SS.csv` (and `_summary.csv`) files from `~/.local/share/goverlay/` and `~/.local/share/goverlay/logs/` into `~/.local/share/goverlay/logs/<app>/`.
- Add a themed **GPLOT** button (`FGplotBtn`) inside `FExtLogCard` in the MangoHud `Extras` tab (`mangohud_ui.pas`).
- Implement `gplot_form.pas` (`TgplotForm`) using 100% native FPC/LCL/Qt6 controls and `TPaintBox` / `TBitmap` canvas rendering with Dark/Light MD3 theme support, multi-run comparison, hardware telemetry charts, and PNG export.

**Non-Goals:**
- Modifying MangoHud's internal C++ logging format or requiring external Python/matplotlib libraries.
- Uploading logs to FlightlessMango or third-party web services.

## Decisions

### 1. Native LCL/Qt6 Form (`gplot_form.pas`) vs. External Python Script
- **Decision**: Implement GPLOT natively in Pascal/LCL inside `gplot_form.pas` (`TgplotForm`), accessible both from the **GPLOT** button in the Extras tab and via `goverlay --gplot` on the command line.
- **Rationale**: A native LCL/Qt6 form launches instantaneously, respects GOverlay's Dark/Light theme (`themeunit.pas`), works inside sandboxed packages (Flatpak/AppImage) without requiring `python3-matplotlib` or `python3-numpy`, and can be directly tested in `tests/test_gui.pas`.
- **Alternatives Considered**: Wrapping `mangoplot` or shipping a custom Python script (`matplotlib`). Rejected because `matplotlib` is not guaranteed to be installed on user systems or inside Flatpak runtimes, and native `TCanvas` rendering gives interactive hover tooltips and instant multi-run toggling.

### 2. Per-Game Log Directory Resolution & Auto-Organizer (`OrganizeMangoHudCsvLogs`)
- **Decision**:
  1. In `overlayunit.pas` and `mangohud_ui.pas`, default `logfolderEdit.Text` to `GetGameLogDir(FActiveGameName)`. Note that in `GetGameLogDir('')` (Global mode), we return `~/.local/share/goverlay/logs/`.
  2. When loading a `MangoHud.conf` (`ApplyMangoHudSetting` for `output_folder`), if the configured path equals the legacy root default (`ExcludeTrailingPathDelimiter(GetGOverlayDataDir())`) or if switching to a game profile whose `output_folder` still points to the root/global logs directory, update `logfolderEdit.Text` to `GetGameLogDir(FActiveGameName)` and call `ForceDirectories`.
  3. Before writing `output_folder` in `overlay_config.pas`, call `ForceDirectories(Settings.LogFolder)` so MangoHud never fails due to a missing target directory.
  4. Implement `OrganizeMangoHudCsvLogs(const ABaseDataDir: string)` in `gplot_form.pas` (invoked on GOverlay startup and when opening/refreshing GPLOT). It scans `~/.local/share/goverlay/` and `~/.local/share/goverlay/logs/` for files matching `<prefix>_YYYY-MM-DD_HH-MM-SS.csv` (and `<prefix>_YYYY-MM-DD_HH-MM-SS_summary.csv`), extracts `<prefix>` as the game/app name, creates `~/.local/share/goverlay/logs/<prefix>/`, and moves the file there.
- **Rationale**: Even when a user runs a game under the Global profile (where `output_folder` is `~/.local/share/goverlay/logs/`) or has existing logs in `~/.local/share/goverlay/`, MangoHud prefixes every CSV filename with the executable/app name (`pascube_2026-10-17_14-07-18.csv`). Auto-organizing loose CSVs guarantees every benchmark is neatly grouped under `logs/<game>/`.

### 3. MangoHud CSV Parser & Statistical Percentiles (`TGplotRunData`)
- **Decision**:
  - Parse MangoHud CSVs line by line:
    - Line 1 (`os,cpu,gpu,ram,kernel,driver,cpuscheduler`) + Line 2: Stored in `TGplotSystemSpecs` record.
    - Line 3: Dynamic column index map (`fps`, `frametime`, `cpu_load`, `cpu_power`, `gpu_load`, `cpu_temp`, `gpu_temp`, `gpu_core_clock`, `gpu_mem_clock`, `gpu_vram_used`, `gpu_power`, `ram_used`, `elapsed`) so optional/missing columns in older or newer MangoHud versions degrade gracefully.
    - Line 4+: Numeric telemetry samples (`TGplotSample` dynamic array). Convert `elapsed` (microseconds in MangoHud CSVs) to relative seconds `(Sample.Elapsed - FirstElapsed) / 1e6`.
  - Compute summary statistics directly from the `fps` and `frametime` sample arrays:
    - `AvgFps`, `MinFps`, `MaxFps`, `AvgFrametimeMs`.
    - `Fps1Low` (1st percentile of sorted `fps` samples) and `Fps01Low` (0.1th percentile of sorted `fps` samples), valid for any sample count $\ge 1$.
    - Hardware averages/peaks: `AvgGpuLoad`, `AvgCpuLoad`, `MaxGpuTemp`, `MaxCpuTemp`, `AvgGpuPower`, `AvgCpuPower`, `MaxVramUsed`.

### 4. UI Layout of `FExtLogCard` and `TgplotForm`
- **Decision**:
  - **Extras Tab (`mangohud_ui.pas`)**: Add `FGplotBtn: TSpeedButton` (or custom-painted `TPaintBox`/button matching `FLoggingCaptureBtn` styling) inside `FExtLogCard` at `X4` (to the right of `FLoggingCaptureBtn` at `Y = 127 + HDR`), with label `FExtGplotLabel` (`"Benchmark viewer"`) at `Y = 106 + HDR`.
  - **GPLOT Window (`TgplotForm`)**:
    - **Top Toolbar**: Game selector (`TComboBox`), `Refresh` button, `Open Folder` button, `Delete Run` button, and `Export PNG` button.
    - **Left Sidebar**: Multi-select run list (`TCheckListBox` or custom checkable list) displaying run timestamp, duration, and average FPS, plus `Select All` / `Clear` helpers.
    - **Right Main Area**:
      - View selector tabs/buttons: `FPS & Frametime`, `Summary Comparison`, `Hardware Telemetry`.
      - Interactive `TPaintBox` chart canvas (double-buffered, renders time-series line plots or horizontal comparison bars with color-coded series palette and mouse-hover crosshair tooltip).
      - Bottom Comparative Statistics table/panel and System Specs status bar.

## Risks / Trade-offs

- **[Risk] Very large CSV files (e.g., 1-hour run with 36,000+ points) slowing down `TPaintBox` polyline rendering** → **Mitigation**: Downsample/bucket points to screen pixel width (e.g., max ~1,000 plotted vertices per series) during canvas rendering while computing statistical metrics (`Avg`, `1% Low`, `0.1% Low`) on the full un-decimated dataset.
- **[Risk] Companion `*_summary.csv` files appearing as empty/broken runs** → **Mitigation**: Explicitly filter out any filename ending with `_summary.csv` (case-insensitive) during run discovery, and move/delete `_summary.csv` alongside its parent `.csv` file.
