## Context

See `proposal.md` - Why.

MangoHud presets modify `TCheckBox.Checked` values directly in code (e.g. `SetAllCheckBoxesToFalse`, `fpsCheckbox.Checked := True`, `fullBitBtnClick`, `basicBitBtnClick`). Because `TToggleSwitch` maintains an internal `FChecked` property and does not listen to `TCheckBox.Checked` direct assignment events from LCL, `SyncAllToggles` must be called explicitly when preset options or bulk checkbox operations occur.

## Goals / Non-Goals

**Goals:**
- Guarantee that selecting any MangoHud preset (Full, Basic, Basic Horizontal, FPS Only, User Custom) immediately updates the visual states of all `TToggleSwitch` controls on the Metrics, Visual, Performance, and Extras tabs.
- Ensure sub-tab `OnShow` events invoke the corresponding `Sync*Toggles` methods to prevent any desync when navigating between tabs.
- Add GUI automated tests verifying preset toggle synchronization.

**Non-Goals:**
- Modifying the preset definitions or MangoHud config parameters.
- Changing `TToggleSwitch` rendering or drawing logic.

## Decisions

1. **Centralized Sync in `TMangoHudUiHelper.PresetCardClick` and Preset BitBtn handlers**:
   - *Rationale*: Preset actions are the primary way users bulk-modify MangoHud options. Invoking `SyncAllToggles` after applying the preset updates the entire UI in one atomic step.
   - *Alternative Considered*: Overriding `TCheckBox.OnChange` globally. *Rejected* because changing `TCheckBox.Checked` programmatically does not reliably fire `OnChange` in LCL when controls are hidden/not focused, and risked overwriting existing form-level event handlers.

2. **Hooking `SetAllCheckBoxesToTrue` and `SetAllCheckBoxesToFalse`**:
   - *Rationale*: These helper procedures are used across multiple preset and reset workflows. Hooking `SyncAllToggles` here ensures complete coverage.

3. **Sub-Tab `OnShow` Synchronization**:
   - *Rationale*: Provides a safety net ensuring that whenever `visualTabSheetShow`, `performanceTabSheetShow`, `metricsTabSheetShow`, or `extrasTabSheetShow` is invoked, the visible tab's toggles are refreshed from the active configuration.

## Risks / Trade-offs

- **[Risk] Multiple fast sync calls during preset apply**: → `SyncAllToggles` only iterates small lists of 10-25 controls and checks `if FChecked <> FLinkedCheckBox.Checked then Invalidate`, which is instantaneous (<0.1ms).
