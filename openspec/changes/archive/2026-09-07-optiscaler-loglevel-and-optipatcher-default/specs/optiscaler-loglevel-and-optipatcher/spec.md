## Purpose
Provides user interface controls and configuration persistence for OptiScaler file log verbosity levels and ensures the OptiPatcher plugin is enabled by default while remembering user deactivation.

## ADDED Requirements

### Requirement: OptiScaler LogLevel Selection UI
The system SHALL display a "Log level" combobox with descriptive verbosity options and an explanatory tooltip inside the Main sub-card of the OptiScaler tab.

#### Scenario: Displaying LogLevel options
- **WHEN** user opens the OptiScaler configuration tab
- **THEN** the "Log level" combobox is visible below "Menu scale" with options "0 - Trace", "1 - Debug", "2 - Info (Default)", "3 - Warning", and "4 - Error".

#### Scenario: Displaying performance warning in tooltip
- **WHEN** user hovers over the Log level combobox
- **THEN** a tooltip is shown indicating that higher verbosity levels (Trace / Debug) may impact gameplay performance and that the default is 2 (Info).

### Requirement: LogLevel Persistence and Automatic Saving
The system SHALL persist the selected log level in the active OptiScaler configuration file under the `[Log]` section and trigger auto-save upon user interaction.

#### Scenario: Defaulting unconfigured or auto LogLevel
- **WHEN** an OptiScaler configuration is loaded with `LogLevel=auto` or missing in `OptiScaler.ini`
- **THEN** the combobox selects "2 - Info (Default)".

#### Scenario: Auto-saving user selection
- **WHEN** user selects a log level option in the combobox
- **THEN** auto-save is scheduled and the corresponding integer value (0, 1, 2, 3, or 4) is written to `LogLevel=` under `[Log]` in `OptiScaler.ini`.

### Requirement: OptiPatcher Default Enabled with State Memory
The system SHALL initialize the OptiPatcher plugin toggle to enabled by default when unconfigured or set to auto, while preserving explicit user deactivation.

#### Scenario: Fresh or auto configuration enables OptiPatcher
- **WHEN** OptiScaler configuration is loaded and `LoadAsiPlugins` is set to `auto` or missing
- **THEN** the OptiPatcher toggle switch is enabled (Checked = True).

#### Scenario: Explicit deactivation is remembered
- **WHEN** user turns off the OptiPatcher toggle and the configuration is saved
- **THEN** `LoadAsiPlugins=false` is persisted to `OptiScaler.ini` and subsequent reloads keep OptiPatcher disabled.
