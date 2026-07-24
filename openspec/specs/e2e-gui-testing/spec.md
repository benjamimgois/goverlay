## Purpose
Define the requirements for automated integration testing of the GOverlay GUI interface, replacing the previous pixel-coordinate E2E approach with deterministic in-process testing.

## Requirements

### Requirement: In-Process Offscreen GUI Testing

The GUI test suite SHALL instantiate the real `Tgoverlayform` in-process using the Qt6 `offscreen` platform (`QT_QPA_PLATFORM=offscreen`), requiring no X server, virtual framebuffer, window manager, or mouse synthesis.

Form instantiation itself SHALL be treated as a smoke test: the LCL streaming system validates every `.lfm` event binding at load time, so a missing or renamed handler fails the suite immediately.

#### Scenario: Offscreen form smoke test
- **WHEN** the GUI test harness starts with `QT_QPA_PLATFORM=offscreen` and an isolated `HOME`
- **THEN** `Tgoverlayform` is created successfully with all `.lfm` bindings resolved, and the process exits cleanly after the suite finishes

### Requirement: Deterministic Test Mode

The application SHALL skip network update checks and background download/install threads during startup when the environment variable `GOVERLAY_TEST=1` is set. When the variable is absent, startup behavior SHALL be unchanged.

#### Scenario: Test-mode startup performs no network activity
- **WHEN** the application starts with `GOVERLAY_TEST=1`
- **THEN** `FormCreate` completes without invoking update checks or starting background download threads

#### Scenario: Normal startup unchanged
- **WHEN** the application starts without `GOVERLAY_TEST` set
- **THEN** startup behaves exactly as before this change (update checks and background threads run normally)

### Requirement: Programmatic UI Interaction and Assertion

GUI tests SHALL drive controls through the LCL event chain (`TControl.Click` for buttons/labels, assigning `TRadioButton.Checked` for radio options) and SHALL assert outcomes on both configuration files and control state (`Enabled`/`Checked`). Tests MUST be falsifiable: no assertion may be satisfiable by pre-seeded fixture data alone.

#### Scenario: GPU driver toggle round-trip
- **WHEN** the test sets `mesaRadioButton.Checked := True` and then `nvidiaRadioButton.Checked := True`
- **THEN** `goverlay.conf` contains `GpuDriver=mesa` after the first action and `GpuDriver=nvidia` after the second, and the NVIDIA action leaves `forcereflexCheckBox.Enabled = False` and `spoofCheckBox.Checked = False`

#### Scenario: Sidebar navigation switches active tab
- **WHEN** the test invokes `Click` on the OptiScaler sidebar label
- **THEN** the main page control's active page is the OptiScaler tab sheet

### Requirement: Isolated Test Configuration Environment

Each test run SHALL execute with `HOME` pointed at a fresh temporary directory, seeded only with the minimal fixtures required (e.g. `ChangelogSeenVersion` to suppress the changelog popup). The temporary directory SHALL be deleted on success and preserved with a printed path on failure.

#### Scenario: Test run does not touch real user configuration
- **WHEN** any test in the suite runs
- **THEN** all application file writes occur under the temporary mock `HOME`, and the developer's real `$HOME/.config/goverlay` remains untouched

### Requirement: Headless Logic Layer Testing

Configuration read/write logic (GPU driver preference, OptiScaler INI round-trips) SHALL be covered by fpcunit tests that link no GUI units and run without a display.

#### Scenario: Driver preference round-trip
- **WHEN** the logic test saves a GPU driver preference and loads it back within an isolated `HOME`
- **THEN** the loaded value equals the saved value for both `mesa` and `nvidia`

