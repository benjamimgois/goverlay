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
