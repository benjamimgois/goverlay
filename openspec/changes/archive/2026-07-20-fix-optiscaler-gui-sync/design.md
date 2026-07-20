## Context

Under GOverlay's current implementation, switching GPU Driver selection (NVIDIA <-> MESA) synchronously saves the driver to `config.ini` but does not persist the toggled state of dependent configuration options (`Spoof DLSS`, `Force Reflex`) to the `OptiScaler.ini` and `fakenvapi.ini` configuration files. Consequently, navigating away from the OptiScaler tab and returning loads the unpersisted configuration files, resetting the checkboxes and producing a UI desynchronization bug.

Additionally, global navigation (`FActiveGameName = ''`) does not call `ApplyToolEnabledState` or `SetSaveBtnEnabled` when selecting vkBasalt, OptiScaler, or Tweaks. This causes the Save button state to get stuck in the state of whatever tab was visited last.

## Goals / Non-Goals

**Goals:**
- Guarantee that toggling MESA/NVIDIA selection synchronously saves the state of spoofing and reflex configuration options on disk.
- Make the main Save button state consistent in global navigation mode when switching between tabs.

**Non-Goals:**
- Rewrite the `LoadOptiScalerConfig` logic to implement a dirty-state checking mechanism (too complex for a bugfix).

## Decisions

### Invoke `SaveOptiScalerConfig` on GPU Radio Button Click

**Decision:** Add calls to `SaveOptiScalerConfig` at the end of both `mesaRadioButtonChange` and `nvidiaRadioButtonChange`.

**Rationale:** This ensures that when the driver selection changes (and the checkboxes are automatically updated by the GUI), the new values of `Spoof DLSS` and `Force Reflex` are written to `OptiScaler.ini` and `fakenvapi.ini` immediately. This matches the synchronous save behavior of `SaveOptiScalerDriverPreference` and avoids the UI desynchronization on tab change.

### Remove `FActiveGameName <> ''` Guard in tab clicks

**Decision:** Remove the `if FActiveGameName <> '' then` check around `ApplyToolEnabledState` and `SetSaveBtnEnabled` in the click event handlers for `optiscalerLabel`, `vkbasaltLabel`, and `tweaksLabel`.

**Rationale:** The `FNavToolEnabled` state array is properly populated in global mode. Removing the guard forces GOverlay to update the Save button and tab control states according to the current tool's global enable state, resolving UI state leakages between tabs.

## Risks / Trade-offs

- **[Risk] Unnecessary disk writes** — saving configuration files on every rádio button change adds minor I/O overhead.
  → **Mitigation:** The GPU driver selection is changed very infrequently (usually only once on first setup), so the I/O impact is negligible.
