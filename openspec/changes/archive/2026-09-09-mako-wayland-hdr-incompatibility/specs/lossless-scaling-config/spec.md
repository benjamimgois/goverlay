## ADDED Requirements

### Requirement: MAKO Incompatibility Conflict Guard with Wayland and HDR
The system SHALL automatically prevent conflicting execution of the MAKO renderer with Wayland native Proton mode and HDR mode. When MAKO is the active interpolation method:
1. The system SHALL display a non-blocking floating toast notification informing the user that Wayland and HDR have been disabled due to MAKO incompatibility.
2. The system SHALL display an informational note `(Wayland and HDR envvars are disabled with MAKO)` beside the MAKO version on the Software status card.
3. The system SHALL deactivate and disable the "Enable Wayland" and "Enable HDR" toggles in the EnvVars tab.
4. The system SHALL exclude `PROTON_ENABLE_WAYLAND`, `PROTON_ENABLE_HDR`, `ENABLE_HDR_WSI`, and `DXVK_HDR` from the generated launch environment command and prune them from `bgmod.conf` when saving.
5. When switching from MAKO to `lsfg-vk` or `none`, the system SHALL re-enable the "Enable Wayland" and "Enable HDR" toggles and restore their saved values.

#### Scenario: Selecting MAKO method in Lossless Scaling tab
- **WHEN** user selects the MAKO method in the Lossless Scaling tab
- **THEN** system displays a floating toast notification about Wayland and HDR incompatibility, shows `(Wayland and HDR envvars are disabled with MAKO)` in the Software status card, and deactivates and disables the Wayland and HDR toggles on the EnvVars tab.

#### Scenario: Switching from MAKO to lsfg-vk or None
- **WHEN** user changes the interpolation method from MAKO to lsfg-vk or None
- **THEN** the "Enable Wayland" and "Enable HDR" toggles on the EnvVars tab are re-enabled and their previous checked states are restored.

#### Scenario: Launching games with MAKO active
- **WHEN** user launches a game with MAKO enabled
- **THEN** the launch command does not include `PROTON_ENABLE_WAYLAND`, `PROTON_ENABLE_HDR`, `ENABLE_HDR_WSI`, or `DXVK_HDR` even if previously saved in custom config.
