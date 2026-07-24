## Context

Existing test procedures in `tests/gui/gui_test_cases.pas` followed a write-only pattern: setting UI controls, calling `Save...`, and using `AssertTrue(Pos(..., C) > 0)` to verify text lines in config files. However, this did not test whether GOverlay could successfully read the configuration back from the file into the UI controls without loss of state.

## Goals / Non-Goals

**Goals:**
- Update `TestMangoVisualTab`, `TestMangoMetricsGpuTab`, `TestMangoMetricsCpuTab`, `TestMangoMetricsMemIoTab`, `TestMangoMetricsOtherTab`, `TestMangoPerformanceTab`, and `TestMangoExtrasTab` in `tests/gui/gui_test_cases.pas` to execute `goverlayform.LoadMangoHudConfig` and assert UI control states.
- Update `TestOptiScaler*` tests to verify `LoadOptiScalerConfig` restores UI control states.
- Add `TestTabSwitchingPersistence` to simulate sidebar tab navigation (`mangohudLabelClick`, `optiscalerLabelClick`, etc.) and verify zero state regression.

**Non-Goals:**
- Changing application source code behavior (unless new test assertions uncover pre-existing bugs).

## Decisions

### Decision 1: Structure of Round-Trip Test Assertion
In each tab test procedure:
1. Set UI controls to non-default values.
2. Call Save helper (`SaveMango`, `SaveOpti`).
3. Assert file text contains saved keys/values.
4. Call Reload helper (`goverlayform.LoadMangoHudConfig`, etc.).
5. Assert UI controls (`Checked`, `ItemIndex`, `ButtonColor`, `Position`, `Text`, `Value`) match configured values.

## Risks / Trade-offs

- [Risk] Increasing test execution time.
  - *Mitigation*: Loading local config files in memory takes <5ms; full test suite execution time increase will be negligible.
