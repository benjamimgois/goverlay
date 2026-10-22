## Context

See `proposal.md` - Why.
`WireAutoSaveEvents` binds LCL controls to `@GenericControlClick` and `@GenericControlChange` to trigger auto-saving. `TToggleSwitch` controls and programmatic checkbox updates did not trigger auto-saving because only mouse clicks on checkboxes were intercepted.

## Goals / Non-Goals

**Goals:**
- Enable automatic persistence for all `TToggleSwitch` and `TCheckBox` controls across the application.
- Prevent orphan/duplicate dynamic controls in `optiscaler_tab.pas`.
- Maintain full compatibility with headless tests, configuration serialization, and existing click handlers.

**Non-Goals:**
- Modifying INI serialization logic or file formats.

## Decisions

### Decision 1: Dual OnClick & OnChange Binding in WireAutoSaveEvents
- **Rationale**: `TCheckBox` controls modified via code (e.g. `TToggleSwitch.LinkToCheckBox`) trigger `OnChange`, while user clicks on standalone checkboxes trigger `OnClick`. Binding both handlers ensures changes by either path trigger the auto-save timer.
- **Alternatives considered**:
  - Binding only `TToggleSwitch.OnChange`: Misses any standalone checkboxes modified programmatically.
  - Adding manual auto-save triggers in each tab: Fragile and prone to regressions.

### Decision 2: Native TToggleSwitch Support in WireAutoSaveEvents
- **Rationale**: `TToggleSwitch` derives from `TCustomControl` (a `TWinControl` child), so `WireAutoSaveEvents` can detect `Ctrl is TToggleSwitch` and attach its `OnChange` event handler directly.

### Decision 3: Singleton Guard on Dynamic Control Creation
- **Rationale**: `forceFsr4Int8CheckBox` should only be created if it is currently `nil` to prevent orphan controls and preserve linkage with its corresponding `TToggleSwitch`.

## Risks / Trade-offs

- **[Risk] Multiple auto-save triggers during form loading** → *Mitigation*: Existing `FLoadingConfig` check in `GenericControlChange` and `TriggerAutoSave` drops events while loading.
