## Context

See `proposal.md` for motivation. The OptiScaler tab (`optiscaler_tab.pas`) currently uses standard LCL `TCheckBox` controls in Card 1 (Options). MangoHud and Lossless Scaling tabs use `TToggleSwitch` (defined in `toggle_switch.pas`), which wraps underlying checkboxes with `LinkToCheckBox(ACheckBox)` for seamless two-way state synchronization, SDF antialiasing, and neon glow effects.

## Goals / Non-Goals

**Goals:**
- Wrap all 6 active checkboxes in `optiscaler_tab.pas` (`optipatcherCheckBox`, `spoofCheckBox`, `forceFsr4Int8CheckBox`, `emufp8CheckBox`, `forcereflexCheckBox`, `forcelatencyflexCheckBox`) with `TToggleSwitch`.
- Reposition and align companion controls (`FOsPatcherListBtn` 🔗 button) seamlessly next to the toggle text.
- Maintain full synchronization in `LoadOptiScalerConfig` and `InitOptiScalerTab`.
- Maintain 100% test suite pass rate in `make test-logic` and `make test-gui`.

**Non-Goals:**
- Modifying INI serialization formats or key names.
- Redesigning the OptiScaler tab layout grid beyond toggle alignment.

## Decisions

- **Decision 1: Use `LinkToCheckBox` Wrapper Pattern**
  - *Rationale*: Keeps existing event handlers, INI loading/saving logic, and test cases that interact with `TCheckBox` untouched while seamlessly rendering `TToggleSwitch`.
  - *Alternative Considered*: Replacing `TCheckBox` directly in `overlayunit.pas` / `overlayunit.lfm`. This would require extensive refactoring of form files, serialization methods, and tests.

- **Decision 2: Dynamic Companion Alignment for `FOsPatcherListBtn`**
  - *Rationale*: In `ReflowOptiScalerTabNew`, place `FOsPatcherListBtn` at `FOptiPatcherToggle.Left + FOptiPatcherToggle.Width + 4`.

- **Decision 3: Maintain List of Toggles for Batch Synchronization**
  - *Rationale*: Store toggles in `FOsToggles: TFPList` to allow efficient `SyncFromLinked` updates when config is loaded.

## Risks / Trade-offs

- [Risk: Toggle bounds clipping in narrow widths] → Mitigation: Height is fixed to 20px, and width uses `GetOptimalWidth` or `ColW - 20`, bounded within each sub-card's available width.
- [Risk: Visibility desync for conditional toggles (e.g. `forceFsr4Int8CheckBox`)] → Mitigation: Sync visibility between `TCheckBox` and `TToggleSwitch` during initialization and framegen/spatial option changes.
