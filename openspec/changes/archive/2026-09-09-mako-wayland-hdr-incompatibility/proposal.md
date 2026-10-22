## Why

The MAKO frame generation and spatial scaling renderer is currently incompatible with Wayland native Proton mode (`PROTON_ENABLE_WAYLAND=1`) and HDR mode (`PROTON_ENABLE_HDR=1`, `ENABLE_HDR_WSI=1`, `DXVK_HDR=1`). Enabling these options concurrently leads to rendering pipeline conflicts, game initialization failures, or silent frame generation crashes. Automating the deactivation and disabling of these environment variables whenever MAKO is active prevents misconfigurations while keeping the user clearly informed.

## What Changes

- **Automatic Conflict Guard**: When the user activates the MAKO method in the Lossless Scaling tab:
  - Displays a non-blocking floating toast notification informing the user that Wayland and HDR are incompatible with MAKO and have been disabled.
  - Displays a persistent informational note beside the MAKO version on the "Software status" card: `(Wayland and HDR envvars are disabled with MAKO)`.
  - Automatically unchecks (`Checked := False`) and disables (`Enabled := False`) the "Enable Wayland" and "Enable HDR" toggles in the EnvVars tab.
  - Guards launch environment generation (`GetTweaksLaunchEnv`) and configuration saving (`SaveLosslessConfig`) to ensure Wayland and HDR variables are never exported or persisted while MAKO is active.
- **State Restoration**: When switching from MAKO back to `lsfg-vk` or `none`:
  - Re-enables the "Enable Wayland" and "Enable HDR" toggles (`Enabled := True`).
  - Restores their previously saved checked states from configuration / session memory.
- **Visual Feedback on EnvVars Tab (`tweaks_md3.pas`)**:
  - Updates `DrawToggle` and `DrawItem` to visually render disabled items in a dimmed/grayed-out style.
  - Blocks toggling on mouse click (`MouseDown`) for disabled items and informs the user.
  - Displays an explanatory hover hint (`MouseMove`) indicating that the option is disabled due to MAKO.
- **Test Isolation and Reliability**:
  - Ensures test cleanup across GUI tests so that method switching does not leak state across test cases.

## Capabilities

### Modified Capabilities
- `lossless-scaling-config`: Adds MAKO conflict management with Wayland and HDR environment variables, including UI notices, launch command filtering, and config serialization safety.
- `envvars-tab-card-redesign`: Adds disabled state support for tweak toggles, including dimmed rendering, interaction guards, and conflict hover hints.

## Impact

- `lossless_scaling_tab.pas`: Handles MAKO method selection notifications, status card note, and config stripping.
- `tweaks_md3.pas`: Implements disabled toggle styling, interaction blocking, and hover tooltips.
- `overlayunit.pas`: Implements `IsMakoActive`, `SyncMakoEnvVarsState`, and launch environment filtering in `GetTweaksLaunchEnv`.
- `tests/gui/gui_test_cases.pas`: Adds GUI verification tests for toggle deactivation/re-enabling and guarantees clean test isolation.
