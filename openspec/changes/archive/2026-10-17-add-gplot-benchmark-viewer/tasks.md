# Tasks

## 1. Per-Game MangoHud CSV Directory & Auto-Organizer

- [x] 1.1 Update `GetGameLogDir`, `ResetMangoHudDefaults` (`mangohud_ui.pas`), `FormCreate` (`overlayunit.pas`), `ApplyMangoHudSetting` (`MANGO_KEY_OUTPUT_FOLDER`), and `overlay_config.pas` so `logfolderEdit.Text` defaults to `~/.local/share/goverlay/logs/<GameDirName>/` (or `~/.local/share/goverlay/logs/` in Global mode), upgrades legacy `~/.local/share/goverlay` paths on load/game switch, and calls `ForceDirectories` before saving; verify by compiling `lazbuild goverlay.lpi` with zero errors.
- [x] 1.2 Implement `OrganizeMangoHudCsvLogs` in `pasplot_form.pas` to move loose `<app>_YYYY-MM-DD_HH-MM-SS.csv` and `<app>_YYYY-MM-DD_HH-MM-SS_summary.csv` files from `~/.local/share/goverlay/` and `~/.local/share/goverlay/logs/` into `~/.local/share/goverlay/logs/<app>/`, and add unit tests in `tests/gui/gui_test_cases.pas` verifying directory organization and legacy `output_folder` upgrade.

## 2. PasPlot CSV Parser & Statistics Engine

- [x] 2.1 Create `pasplot_form.pas` with `TGplotSystemSpecs`, `TGplotSample`, `TGplotRunData`, and `ParseMangoHudCsvFile` supporting arbitrary sample counts (including <10,000 samples) and arbitrary frame rates (including >1,000 FPS), dynamic column header mapping, `*_summary.csv` filtering, and computation of Average FPS, 1% Low FPS, 0.1% Low FPS, Min/Max FPS, Average Frametime (ms), and hardware telemetry averages/peaks; verify with `lazbuild goverlay.lpi`.
- [x] 2.2 Add unit tests in `tests/gui/gui_test_cases.pas` testing `ParseMangoHudCsvFile` on synthetic and 60-second `pascube`-style high-FPS (>9,000 FPS, 600 samples) CSV data and verifying `_summary.csv` exclusion; run `./tests/gui/gui_tests` and verify all tests pass.

## 3. Native PasPlot Benchmark Viewer Window (`TpasplotForm`) & Extras Tab UI Integration

- [x] 3.1 Implement `TpasplotForm` (`TgplotForm`) in `pasplot_form.pas` with Dark/Light MD3 theme support, Game selector (`TComboBox`), multi-select Run list (`TCheckListBox`), three visualization tabs (`FPS & Frametime`, `Summary Comparison`, `Hardware Telemetry`), interactive `TPaintBox` chart renderer with hover tooltip, Comparative Statistics table (`Δ %`), System Specs status bar, `Refresh`, `Open Folder`, `Delete Run`, and `Export PNG` actions; verify compilation with `lazbuild goverlay.lpi`.
- [x] 3.2 Add the `PasPlot` button (`FGplotBtn`) and label (`FExtGplotLabel`) inside `FExtLogCard` in `mangohud_ui.pas` (`ReparentExtrasTab`, `ReflowExtrasTab`, and theme styling), wire its click handler in `overlayunit.pas` to open `PasPlot` pre-selecting `FActiveGameName`, and add `--pasplot` (and `--gplot`) CLI flag support in `goverlay.lpr`; verify compilation with `lazbuild goverlay.lpi`.
- [x] 3.3 Add GUI tests in `tests/gui/gui_test_cases.pas` verifying `FGplotBtn` (`Caption = 'PasPlot'`) placement in `FExtLogCard`, `TpasplotForm` instantiation, multi-run comparison state, and PNG export generation; run `lazbuild --ws=qt6 tests/gui/gui_tests.lpi && ./tests/gui/gui_tests` and confirm 100% test pass rate.

## Workflow follow-up

- Archive the change (`openspec archive`) after implementation and verification are complete.
