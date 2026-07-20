## Context

Our implementation of saving the configuration when the GPU driver changes (`SaveOptiScalerConfig` inside `mesaRadioButtonChange` and `nvidiaRadioButtonChange`) triggers two unintended side effects:
1. It sends a "configuration saved" desktop notification on startup because GOverlay programmatically ticks the rádio button to match the user's last saved driver.
2. It shows the command panel (the black bar at the bottom) and sends desktop notifications every time the user toggles MESA/NVIDIA manually, which is noisy and visually disruptive.

## Goals / Non-Goals

**Goals:**
- Eliminate startup configuration saves when loading the saved driver.
- Make the GPU driver toggling save the configuration silently (no desktop notifications and no command panel updates/invalidations).

**Non-Goals:**
- Completely mute the "Save" button. Clicking the primary green "Save" button on the bottom bar should still trigger desktop notifications and update the command panel as expected.

## Decisions

### 1. Introduce `FOsDriverLoading` Boolean Flag in Form Class

**Decision:** Declare `FOsDriverLoading: Boolean;` under `Tgoverlayform` and wrap the startup driver loading block inside a `try .. finally` block to toggle it.

**Rationale:** When `FOsDriverLoading` is `True`, the driver change events (`nvidiaRadioButtonChange` / `mesaRadioButtonChange`) will skip the `SaveOptiScalerConfig` call. This prevents writing files and firing notifications during initialization.

### 2. Add `ASilent: Boolean` Parameter to `SaveOptiScalerConfig`

**Decision:** Modify `SaveOptiScalerConfig` definition to accept `ASilent: Boolean = False`.

**Rationale:** If `ASilent` is `True`, GOverlay will skip:
- `SendNotification` call.
- `commandPanel.Visible := True` and `commandPaintBox.Invalidate` updates.
This allows programmatic saving from driver-changing events without distracting the user.

## Risks / Trade-offs

- **[Risk] State mismatches if silent saves fail** — if a silent save fails, the user won't get a notification.
  → **Mitigation:** We still display error messages if `SaveOptiScalerConfigCore` fails (`ShowMessage(ErrMsg)`), so critical failures (like disk full / write permissions) are still visible. Only success notifications are silenced.
