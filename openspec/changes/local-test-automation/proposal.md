## Why

The current E2E test approach (`tests/run_e2e_tests.py`, coordinate-based xdotool clicking) is unreliable and unfalsifiable: it reverse-engineers runtime-computed widget positions, depends on host WM/focus/network state, and its MESA assertion passes even when the click misses (the mock config is pre-seeded with the asserted value). Recent GPU driver toggle regressions proved we need regression tests that run locally and deterministically before code is committed.

## What Changes

- **Replace** the coordinate-based E2E strategy with in-process, display-free automated tests:
  - **Logic layer**: fpcunit console tests for config read/write units (driver preference, OptiScaler INI round-trips) — no GUI at all.
  - **GUI wiring layer**: instantiate the real `Tgoverlayform` with the Qt6 `offscreen` platform and drive controls programmatically (`TControl.Click`, `TRadioButton.Checked := ...`), asserting on config files and control state.
- **Add test-mode guard**: `FormCreate` skips network update checks and background download threads when `GOVERLAY_TEST=1`, making startup deterministic.
- **Add local gate**: `make test` target running both layers; optional `pre-push` git hook so only tested code is committed/pushed.
- **Retire** `tests/run_e2e_tests.py` (xdotool/Xvfb sweep approach).

## Capabilities

### New Capabilities
- `local-test-gate`: Local test entry point (`make test`) and git hook wiring that gates commits/pushes on passing tests.

### Modified Capabilities
- `e2e-gui-testing`: Requirements replaced wholesale — headless virtual-X/pixel-sweep execution is superseded by in-process offscreen form testing plus headless logic tests; determinism and falsifiability become hard requirements.

## Impact

- **New code**: `tests/logic/` (fpcunit runner + logic tests), `tests/gui/` (LCL offscreen test harness project), `Makefile` `test` target.
- **Modified code**: `overlayunit.pas` `FormCreate` (test-mode guard, ~5 lines, no behavior change when env var absent).
- **Removed**: `tests/run_e2e_tests.py` and its Xvfb/xdotool/ImageMagick dependencies.
- **Dependencies**: fpcunit (`consoletestrunner`, ships with FPC), Qt6 offscreen platform plugin (`libqoffscreen`) — both verified locally before implementation.
- **No runtime/user-facing impact**: test mode is opt-in via environment variable.
