## Context

GOverlay is a Lazarus/FPC application (LCL, Qt6 widgetset) with UI logic split between `.lfm` event bindings and handlers in large units (`overlayunit.pas`, ~8.3k lines). Regressions typically occur in three places: (1) config read/write logic, (2) `.lfm` ↔ handler wiring lost during UI refactors, (3) handler side effects (checkbox states, config saves). The retired python E2E script tested pixels instead of behavior and failed unfalsifiably.

Local facts that shape the design: FPC 3.2.2 + lazbuild available; build via `make` (lazbuild, qt6); `GetConfigFilePath` resolves under `$HOME` (proven mockable); `FormCreate` performs network update checks and spawns threads (needs taming for determinism).

## Goals / Non-Goals

**Goals:**
- Deterministic, display-free tests runnable locally in seconds-to-a-minute.
- Cover regression classes 1–3: config logic, `.lfm` wiring, handler side effects.
- Gate commits locally: `make test` + git hook; only tested code gets committed.
- Zero behavior change in production binary when tests are not running.

**Non-Goals:**
- Pixel/layout/rendering verification (human eyeball territory; layout is in active churn).
- CI pipelines (GitHub Actions) — local gate only, though nothing blocks adding CI later.
- Full UI coverage — pilot covers OptiScaler driver toggle + navigation smoke; expansion is incremental.
- Screenshot comparison, OCR, AT-SPI, or any X-server-dependent automation.

## Decisions

### D1: In-process offscreen form over all external-driving alternatives

Drive the real `Tgoverlayform` inside a dedicated test program using `QT_QPA_PLATFORM=offscreen`. No X server, no window manager, no mouse synthesis.

Alternatives considered:
- **xdotool/Xvfb pixel clicking (status quo)** — rejected: reverse-engineers runtime layout math (`ReflowOptiScalerTabNew`), broken by any reflow/anchor/DPI change; environment-sensitive (focus, WM, network popups).
- **AT-SPI / dogtail** — rejected: driver radio buttons are 20×20 caption-less indicators (no accessible name); LCL-Qt6 accessibility tree support is irregular.
- **Test IPC socket in the app** — viable but more invasive (protocol, lifecycle) than direct in-process calls for the same determinism.

Rationale: the event chain under test is `user action → .lfm binding → handler → save`. Calling `TControl.Click` / setting `TRadioButton.Checked` exercises that exact chain; only the X-server "postman" is removed, which was the source of all flakiness.

### D2: Two layers, two test programs

```
tests/logic/logic_tests.lpr   fpcunit console runner, links pure units only
tests/gui/gui_tests.lpr       LCL app (qt6/offscreen), instantiates goverlayform, fpcunit asserts
```

Split rationale: logic tests stay millisecond-fast and GUI-dependency-free; GUI harness pays form-startup cost once. Both exit non-zero on failure → composable in `make test`.

### D3: fpcunit + consoletestrunner (ships with FPC)

Standard, no new dependencies, XML/text output, proper exit codes. Alternative (custom assert procedures) rejected: re-invents reporting and exit-code plumbing.

### D4: Test-mode guard via `GOVERLAY_TEST=1` env var in `FormCreate`

Skips `CheckForUpdatesOnClick` and background download/install threads. Env var over `{$IFDEF TESTBUILD}`: single release binary works for both run and test, no separate build mode to drift out of sync. Guard is the only production-code change (~5 lines); absence of the var = zero behavior change.

### D5: Config isolation via mocked `HOME`

Each GUI test run sets `HOME=<tmpdir>` (and seeds `goverlay.conf` with `ChangelogSeenVersion` to suppress the changelog popup). Proven technique from the retired script — the app resolves config paths under `$HOME`. Temp dir deleted on success, preserved on failure for diagnosis.

### D6: Access controls through the form's component fields / `FindComponent`

Tests reference `goverlayform.mesaRadioButton` etc. directly if field visibility allows; otherwise `goverlayform.FindComponent('mesaRadioButton')`. No production refactor just for testability.

### D7: Local gate = `make test` + `pre-commit` hook (default), `pre-push` variant documented

User requirement: only commit working code → gate at commit time. Hook runs `make -s test`; abort on non-zero. Trade-off accepted: hook adds suite runtime to every commit (mitigated by keeping the suite fast; `git commit --no-verify` remains the escape hatch).

### D8: Retire `tests/run_e2e_tests.py`

Deleted in this change. Its scenarios that matter (driver toggle persistence, tab navigation, save assertions) are re-expressed in the GUI layer. Sweep logic, DPI scaling math, and screenshot plumbing have no successor — deliberately.

## Risks / Trade-offs

- [Qt6 offscreen plugin (`libqoffscreen`) missing on dev machine] → Phase-0 verification task; fallback `QT_QPA_PLATFORM=minimal`, last resort Xvfb wrapper for the GUI layer only.
- [fpcunit/`consoletestrunner` not installed with local FPC] → Phase-0 verification; fallback plain assert-based program with exit codes (keeps architecture, loses reporting niceties).
- [`FormCreate` background threads keep process alive or race assertions] → D4 guard skips them; any thread that still starts must be joined/terminated in test teardown (discovered in pilot).
- [Form startup cost makes pre-commit annoying] → suite target ≤60s; if exceeded, move heavy scenarios to `make test-full` and keep smoke subset in the hook.
- [Async init needs message pumping before controls are valid] → harness calls `Application.ProcessMessages` in setup; pilot validates required pump count.
- [Offscreen Qt quirks (no focus/activation) alter behavior vs real run] → accepted: we test logic and wiring, not window-manager interaction (Non-Goal).

## Migration Plan

1. Phase 0 (go/no-go): verify plugin + fpcunit; spike — offscreen form instantiates and exits cleanly.
2. Phase 1: GUI pilot (form smoke, driver toggle round-trip, OptiScaler tab navigation).
3. Phase 2: logic layer (driver preference + OptiScaler INI round-trips).
4. Phase 3: `make test`, hook installer script, delete python script, update docs.
5. Rollback: tests live under `tests/`; deleting them + reverting the `FormCreate` guard fully restores prior state.

## Open Questions

- Hook default: `pre-commit` (chosen, matches "only commit working code") vs `pre-push` (faster commits, gate later) — revisit if suite runtime grows.
- Second-wave scenarios (MangoHud toggles, vkBasalt, save button) — prioritize by regression pain after pilot lands.
