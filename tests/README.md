# GOverlay Local Test Suite

Automated regression tests for GOverlay, designed to run locally before every
commit. No X server, no display, no mouse synthesis: tests run in-process
against the real application code.

## Architecture

```
tests/
  common/   test_isolation.pas  - shared sandbox: fresh mock HOME, seed
                                  config, re-exec so the FPC runtime sees
                                  the mocked environment from process start
  logic/    logic_tests         - headless fpcunit tests for config logic
                                  (driver preference, OptiScaler INI
                                  round-trips). No GUI needed.
  gui/      gui_tests           - instantiates the real Tgoverlayform with
                                  Qt6 offscreen platform, drives controls
                                  programmatically (OnClick invocations,
                                  TRadioButton.Checked) and asserts on
                                  config files + control state.
```

Key properties:

- **Deterministic**: `GOVERLAY_TEST=1` makes the app skip network update
  checks, background download threads, and the changelog fetch on startup.
- **Isolated**: every run uses a fresh temporary `$HOME`. Real user
  configuration is never touched. The sandbox is deleted on success and
  preserved (path printed) on failure.
- **Falsifiable**: toggle tests assert both transitions, so pre-seeded
  fixture values can never satisfy an assertion by accident.

## Running

```bash
make test          # builds and runs both layers
make test-logic    # logic layer only
make test-gui      # GUI wiring layer only
```

## Commit gate

Install the pre-commit hook to block commits when tests fail:

```bash
sh tests/install-hook.sh
```

Bypass in emergencies with `git commit --no-verify`.

## Writing new tests

- Logic tests: add a `TTestCase` in `logic/logic_test_cases.pas` and
  `RegisterTest` it. Runs in milliseconds, no display.
- GUI tests: add to `gui/gui_test_cases.pas`. The form is created once
  before the suite runs; access controls via `goverlayform.<controlName>`
  and invoke `.OnClick(control)` / set `.Checked` to exercise the real
  `.lfm` event bindings.
