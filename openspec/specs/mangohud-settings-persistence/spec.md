# mangohud-settings-persistence

## Requirements

### Requirement: MangoHud VSYNC setting persistence
The system SHALL support saving and restoring all OpenGL VSYNC options (Adaptive, OFF, -N-, ON, Unset) in `MangoHud.conf` and updating the UI dropdown index correctly.

#### Scenario: User selects Unset for OpenGL VSYNC
- **WHEN** user selects "Unset" in `glvsyncComboBox` and saves the configuration
- **THEN** system writes `gl_vsync=4` to `MangoHud.conf` and retains "Unset" in `glvsyncComboBox` upon tab switch or application restart

#### Scenario: User selects ON or -N- for OpenGL VSYNC
- **WHEN** user selects "ON" or "-N-" in `glvsyncComboBox` and saves the configuration
- **THEN** system writes `gl_vsync=1` for ON and `gl_vsync=n` for -N- to `MangoHud.conf` and correctly restores the corresponding dropdown index when loaded

### Requirement: MangoHud load and FPS color thresholds persistence
The system SHALL parse `fps_color`, `gpu_load_color`, and `cpu_load_color` from `MangoHud.conf` and restore custom color picker button values in the UI.

#### Scenario: Loading custom FPS colors
- **WHEN** `MangoHud.conf` contains `fps_color=FF0000,FF5500,00FF00`
- **THEN** system sets `fpscolor1ColorButton`, `fpscolor2ColorButton`, and `fpscolor3ColorButton` to the corresponding hex colors upon configuration load

#### Scenario: Loading custom GPU load colors
- **WHEN** `MangoHud.conf` contains `gpu_load_color=00FF00,FF5500,FF0000`
- **THEN** system sets `gpuload1ColorButton`, `gpuload2ColorButton`, and `gpuload3ColorButton` to the corresponding hex colors upon configuration load

#### Scenario: Loading custom CPU load colors
- **WHEN** `MangoHud.conf` contains `cpu_load_color=00FF00,FF5500,FF0000`
- **THEN** system sets `cpuload1ColorButton`, `cpuload2ColorButton`, and `cpuload3ColorButton` to the corresponding hex colors upon configuration load

### Requirement: MangoHud GPU device selection persistence
The system SHALL parse `gpu_list` from `MangoHud.conf` and restore the selected GPU in `pcidevComboBox`.

#### Scenario: Loading selected GPU device
- **WHEN** `MangoHud.conf` contains `gpu_list=1` or `gpu_list=0,1`
- **THEN** system sets `pcidevComboBox.ItemIndex` to match the configured GPU selection upon configuration load
