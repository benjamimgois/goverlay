## Context

See `proposal.md` for motivation. Currently:
- `TLosslessScalingTabHelper` manages interpolation method state (`imNone`, `imLsfg`, `imMako`).
- `TTweaksMD3Helper` handles custom painting and mouse interactions for the EnvVars tab.
- `Tgoverlayform` manages the underlying checkboxes (`enwaylandCheckBox`, `enhdrCheckBox`), global launch commands (`GetTweaksLaunchEnv`), and sidebar tool states (`FNavToolEnabled[2]`).

## Goals / Non-Goals

**Goals:**
- Automatically enforce incompatibility guard: uncheck and disable Wayland and HDR toggles when MAKO is active.
- Deliver non-blocking notification (`FFloatingToast`) when MAKO is selected and show a persistent note in the Software Status card.
- Provide visual dimmed styling, mouse interaction guards, and hover hints for disabled toggles in `tweaks_md3.pas`.
- Seamlessly re-enable toggles and restore previous/saved states when switching back to `lsfg-vk` or `none`.
- Protect launch commands and configuration saves from emitting conflicting variables.
- Guarantee strict test isolation across the GUI test suite.

**Non-Goals:**
- Modifying MAKO's internal behavior or upstream code.
- Restricting other unrelated environment variables.

## Decisions

### 1. State Synchronization & Active Condition
- **Decision**: Define `IsMakoActive` as `(FInterpolationMethod = imMako) and FNavToolEnabled[2]`.
- **Implementation**: Implement `SyncMakoEnvVarsState` on `Tgoverlayform` to synchronize `enwaylandCheckBox` and `enhdrCheckBox` properties (`Enabled` and `Checked`) and call `SyncTweaksGridFromCheckBoxes`.
- **Trigger Points**:
  - `SetInterpolationMethod` in `lossless_scaling_tab.pas`.
  - `ApplyToolEnabledState(2, ...)` in `overlayunit.pas`.
  - `LoadTweaksFromFGMod` in `tweaks_md3.pas`.

### 2. State Restoration Logic
- **Decision**: Cache user selections before MAKO deactivation (`FPreMakoWaylandChecked`, `FPreMakoHdrChecked`) in `Tgoverlayform`.
- **Rationale**: When the user switches from MAKO to `lsfg-vk` or `none`, restoring cached states avoids losing user preferences without requiring a disk reload. When loading from disk (`LoadTweaksFromFGMod`), if MAKO is not active, values load directly from `bgmod.conf`.

### 3. Non-Blocking Notification & Status Note
- **Decision**: Use `FFloatingToast.ShowToast('Wayland and HDR are disabled with MAKO')` on interactive selection (`MethodMakoClick`), plus a persistent `FLsMakoNoteLabel` on the Software Status card beside the MAKO version.
- **Rationale**: Non-blocking feedback preserves smooth UX and prevents headless/GUI test runners from blocking on modal dialogs.

### 4. EnvVars Tab Visual & Interaction Feedback (`tweaks_md3.pas`)
- **Decision**:
  - In `DrawToggle` and `DrawItem`, add `AEnabled: Boolean = True` parameter. Render disabled toggles with dark slate track (`RGBToColor(32, 36, 48)`), muted thumb (`RGBToColor(90, 95, 105)`), and muted label text (`RGBToColor(120, 130, 145)`).
  - In `MouseDown`, check `if Assigned(Chk) and not Chk.Enabled then Exit;` to block toggling.
  - In `MouseMove`, display `TweakHint := 'Wayland and HDR envvars are disabled with MAKO'` when hovering over disabled items.

### 5. Config Serialization & Launch Guard
- **Decision**:
  - In `SaveLosslessConfig`: When `FInterpolationMethod = imMako`, delete `PROTON_ENABLE_WAYLAND`, `PROTON_ENABLE_HDR`, `ENABLE_HDR_WSI`, and `DXVK_HDR` from `[Env]` in `bgmod.conf`.
  - In `GetTweaksLaunchEnv`: Omit these variables whenever `IsMakoActive` is true.

### 6. Test Suite Isolation
- **Decision**: Wrap tests that switch interpolation methods (`TestLosslessScalingDynamicConfigFileAndLog`, `TestLosslessScalingMethodSwitching`, `TestMakoDeactivatesWaylandAndHdrEnvVars`) with `try ... finally Helper.SetInterpolationMethod(imNone); end;`.

## Risks / Trade-offs

- **[Risk] State leakage across tests**: If any test leaves `InterpolationMethod := imMako`, subsequent tests that check `enhdrCheckBox` could fail.
  → *Mitigation*: Ensure all tests restoring `imNone` in `finally` blocks.
- **[Risk] Manual edits to bgmod.conf**: A user could manually add `PROTON_ENABLE_WAYLAND=1` to `bgmod.conf`.
  → *Mitigation*: `GetTweaksLaunchEnv` actively suppresses the variable at launch time when MAKO is active.
