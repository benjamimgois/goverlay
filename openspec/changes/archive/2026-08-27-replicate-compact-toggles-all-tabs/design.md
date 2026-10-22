## Context

Following the implementation of `TToggleSwitch` on the Metrics tab, we replicate this control across the remaining tabs in GOverlay (`Visual`, `Performance`, `Extras`, and `Lossless Scaling`).

## Goals / Non-Goals

**Goals:**
- Instantiate `TToggleSwitch` (`tssCompact`, 28x16px) for all checkboxes on `Visual`, `Performance`, `Extras`, and `Lossless Scaling` tabs.
- Link each `TToggleSwitch` to its respective `TCheckBox` using `LinkToCheckBox` to ensure transparent bi-directional state synchronization.
- Update `ReflowVisualTab`, `ReflowPerformanceTab`, `ReflowExtrasTab`, and `LosslessScalingHelper.ReflowTab` to position the toggle switches cleanly.
- Ensure all automated GUI tests pass with 100% success.

**Non-Goals:**
- Altering the configuration keys or formats of `MangoHud.conf` or `gameconfig` INI files.

## Decisions

### Decision 1: Use `LinkToCheckBox` Architecture Across All Tabs
- **Choice**: Link each `TToggleSwitch` directly to its corresponding `TCheckBox`.
- **Rationale**: Completely isolates visual modernization from existing backend persistence routines (`GenerateMangoConfig`, `SaveMangoHudConfigCore`, `LoadMangoHudConfig`, `LoadMangoHudBoolFlag`, etc.), eliminating regression risks.

### Decision 2: Centralized Sync Methods
- **Choice**: Provide `SyncVisualToggles`, `SyncPerformanceToggles`, and `SyncExtrasToggles` in `TMangoHudUiHelper` called from `LoadMangoHudConfig` and `ResetMangoHudControls`.
- **Rationale**: Guarantees that any config load or reset immediately updates every toggle across all tabs.

## Risks / Trade-offs

- **[Risk]** Overlapping controls in dense rows (e.g. Performance Info card).
  - *Mitigation*: The compact 28x16px toggle is narrower than standard checkboxes and leaves ample breathing room across all columns.
