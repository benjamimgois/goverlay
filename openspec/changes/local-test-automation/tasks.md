## 1. Environment Verification (go/no-go)

- [x] 1.1 Verify Qt6 offscreen platform plugin exists (`libqoffscreen`) and a trivial Qt6 app runs with `QT_QPA_PLATFORM=offscreen`
- [x] 1.2 Verify fpcunit + `consoletestrunner` units are available in the local FPC 3.2.2 install (fallback if absent: plain assert-program, same architecture)

## 2. Test-Mode Guard (production code)

- [x] 2.1 Add `GOVERLAY_TEST=1` guard in `Tgoverlayform.FormCreate` (overlayunit.pas) skipping `CheckForUpdatesOnClick` and background download/install threads
- [x] 2.2 Manual smoke: start the app normally (no env var) and confirm update check / threads still run — production behavior unchanged

## 3. GUI Wiring Layer (pilot)

- [x] 3.1 Create `tests/gui/gui_tests.lpi`/`.lpr`: LCL Qt6 program with fpcunit console runner, reusing `overlayunit` and related units
- [x] 3.2 Harness setup: fresh temp `HOME`, seed `goverlay.conf` (`ChangelogSeenVersion` + `GpuDriver=nvidia`), set `QT_QPA_PLATFORM=offscreen` + `GOVERLAY_TEST=1`, create form, pump `Application.ProcessMessages` until controls valid
- [x] 3.3 Smoke test: form instantiates (all `.lfm` bindings resolve) and process exits cleanly
- [x] 3.4 Driver toggle round-trip test: `mesaRadioButton.Checked := True` → assert `GpuDriver=mesa` in conf; `nvidiaRadioButton.Checked := True` → assert `GpuDriver=nvidia`, `forcereflexCheckBox.Enabled = False`, `spoofCheckBox.Checked = False` (both transitions asserted — falsifiable against the seeded value)
- [x] 3.5 Navigation test: `optiscalerLabel.Click` → assert page control's active page is `optiscalerTabSheet`
- [x] 3.6 Teardown: delete temp dir on success; preserve and print path on failure

## 4. Logic Layer

- [x] 4.1 Create `tests/logic/logic_tests.lpi`/`.lpr`: fpcunit console runner linking no GUI-dependent code paths
- [x] 4.2 Driver preference round-trip test (`SaveOptiScalerDriverPreference`/`LoadOptiScalerDriverPreference`, both values, isolated `HOME`); if `themeunit` LCL dependencies block headless linking, move the round-trip into the GUI layer instead and note the constraint
- [x] 4.3 OptiScaler INI round-trip test for settings whose read/write logic lives in pure units

## 5. Gate, Retirement, Docs

- [x] 5.1 Add `test` target to `Makefile`: builds and runs logic + GUI layers, propagates exit codes
- [x] 5.2 Add `tests/install-hook.sh`: symlinks/copies a `pre-commit` hook into `.git/hooks/` running `make -s test` (document `--no-verify` escape hatch)
- [x] 5.3 Delete `tests/run_e2e_tests.py` and `tests/screenshots/`
- [x] 5.4 Update `AGENTS.md` (and `CLAUDE.md` if it documents workflows) with the `make test` workflow
- [x] 5.5 End-to-end verification: `make test` green from clean tree; intentionally break one test → hook blocks commit → revert

## 6. Coverage Expansion: vkBasalt + vkSumi

- [x] 6.1 vkBasalt navigation test: `vkbasaltLabel.OnClick` → `vkbasaltTabSheet` active, `vksumiTabSheet` visible (reshade-shaders dir pre-seeded to skip git auto-download)
- [x] 6.2 vkBasalt CAS toggle test: `casTrackBar` 0 → conf without `effects = cas`; 5 → conf with `effects = cas` (save via `saveBitBtn`)
- [x] 6.3 vkSumi navigation test: `ActivePage := vksumiTabSheet` → `vkSumiTabSheetShow`/`LoadVkSumiConfig` run, `FVsTrackbars` built
- [x] 6.4 vkSumi contrast test: trackbar 150 → `contrast = 0.5` in conf; `FVsRestoreBtn` → `contrast = 0.0` (falsifiable both directions)

## 7. Coverage Expansion: OptiScaler Tab (full)

- [x] 7.1 Fixtures: `SeedOptiScalerFiles` writes realistic `OptiScaler.ini` + `fakenvapi.ini` (core writer only updates existing files)
- [x] 7.2 ImGUI Menu: menu scale (`Scale=1.0/1.5`), shortcut key (`ShortcutKey=0x2d/auto`), capture button binding (modal form not opened)
- [x] 7.3 OptiScaler section: spoof DLSS (`Dxgi=auto/false`, mesa-gated), OptiPatcher (`LoadAsiPlugins=true/auto`), FSR version pinned-to-Latest regression pin + `Fsr4Update`/`FsrAgilitySDKUpgrade`, preferred upscaler (`Dx11/Dx12/Vulkan=xess/dlss`), Force FSR4-i8 (`Fsr4ForceEnableInt8=true/false`), emufp8 (`DXIL_SPIRV_CONFIG` set/removed in bgmod.conf)
- [x] 7.4 FakeNVAPI section: force reflex (`force_reflex=2`/key removed, mesa-gated), latencyflex (`force_latencyflex`+`latencyflex_mode`), trace logs (`enable_trace_logs=1/0`)
- [x] 7.5 DLL/channel: `filenameComboBox` → bgmod.conf `DLL=version.dll/dxgi.dll`; `optversionComboBox` → `OPT_CHANNEL=1/0`
- [x] 7.6 Update buttons: `GOVERLAY_TEST` guard added to `TOptiscalerTab.UpdateButtonClick` (no downloads in tests); both buttons clicked → no-op, no `OptiScaler.dll` appears
- [x] 7.7 Harness lesson encoded: tab navigation reloads config from disk — tests navigate once, then set controls, then save (no navigate-before-save)

## 8. Coverage Expansion: MangoHud Tabs (full)

- [x] 8.1 Navigation + preset: `mangohudLabel.OnClick` → presetTabSheet active, 5 sub-tabs visible; `fullBitBtn` preset checks fps/gpu controls
- [x] 8.2 Visual tab (16 elements): hud title, orientation, alpha, corners, bg/font colors, position grid, offsets, toggle key, no_display, hud_compact, horizontal_stretch
- [x] 8.3 Metrics GPU (20 elements): gpu_text, stats+color, load colors block, vram+color, clocks, temps, fan, power(+limit), efficiency, voltage, throttling(+graph), model, vulkan driver, joule cycler (`flip_efficiency`)
- [x] 8.4 Metrics CPU (11 elements): cpu_text, stats+color, core_load, core_bars via `coreloadtypeBitBtn` cycler, load colors, mhz, temp, power, efficiency, core_type
- [x] 8.5 Metrics Mem/IO (7 elements): io_read/write+color, swap, ram+color, ram_temp, procmem, proc_vram
- [x] 8.6 Metrics Other (18 elements): battery(+color/watt/time), gamepad battery, fps, fps_metrics variants via `fpsavgBitBtn` cycler, frame_timing+color, histogram cycler, frame_count, engine(+color/short), arch, wine(+color), winesync
- [x] 8.7 Performance (20 elements): show_fps_limit, method late/early, toggle key, fps_limit+0-fallback, resolution, refresh, fcat, fex_stats, fsr, hdr, present_mode, fahrenheit, gamemode, vkbasalt, vsync, gl_vsync=n, filter bicubic/retro, af, picmip, fps_color block + fps_value auto-thresholds
- [x] 8.8 Extras (15 elements): distro info+exec, display_server, time(+no_label), version#, media_player+color, network iface, output_folder, log_duration, autostart_log, log_interval, toggle_logging, log_versioning, upload_logs
- [x] 8.9 Side effects: blacklist line auto-created (zenity default), bgmod.conf `GOVERLAY_MANGOHUD=1` + `MANGOHUD_CONFIGFILE`
- [x] 8.10 Harness lessons: `ColorToHTMLColor` emits UPPERCASE hex; radio uncheck must go through the sibling radio
