## ADDED Requirements

### Requirement: MangoHud Vulkan VSync hint accuracy
The system SHALL display an accurate tooltip hint for `vsyncComboBox` that matches MangoHud's Vulkan VSync specification (0 = Adaptive, 1 = Off, 2 = Mailbox mode, 3 = On).

#### Scenario: Display Vulkan VSync tooltip
- **WHEN** user hovers over `vsyncComboBox` in the UI
- **THEN** system displays hint text indicating `0 = Adaptive`, `1 = Off`, `2 = Mailbox mode`, and `3 = On`

## MODIFIED Requirements

### Requirement: MangoHud VSYNC setting persistence
The system SHALL support saving and restoring all Vulkan and OpenGL VSYNC options (Adaptive, OFF, -N-, ON, Unset) in `MangoHud.conf` and updating the UI dropdown index correctly. When Unset is selected for Vulkan or OpenGL VSYNC, the system SHALL omit `vsync` and `gl_vsync` keys from `MangoHud.conf`.

#### Scenario: User selects Unset for OpenGL VSYNC
- **WHEN** user selects "Unset" in `glvsyncComboBox` and saves the configuration
- **THEN** system omits `gl_vsync` from `MangoHud.conf` and retains "Unset" in `glvsyncComboBox` upon tab switch or application restart

#### Scenario: User selects Unset for Vulkan VSYNC
- **WHEN** user selects "Unset" in `vsyncComboBox` and saves the configuration
- **THEN** system omits `vsync` from `MangoHud.conf` and retains "Unset" in `vsyncComboBox` upon tab switch or application restart

#### Scenario: User selects ON or -N- for OpenGL VSYNC
- **WHEN** user selects "ON" or "-N-" in `glvsyncComboBox` and saves the configuration
- **THEN** system writes `gl_vsync=1` for ON and `gl_vsync=n` for -N- to `MangoHud.conf` and correctly restores the corresponding dropdown index when loaded
