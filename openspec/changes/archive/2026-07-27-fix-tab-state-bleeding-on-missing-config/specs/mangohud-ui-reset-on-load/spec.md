# mangohud-ui-reset-on-load

## Purpose
Reset the MangoHud UI controls unconditionally before checking config file existence when loading a configuration.

## MODIFIED Requirements

### Requirement: MangoHud UI control redefinition before load
The system SHALL reset all MangoHud-specific UI controls on the main form to their default values unconditionally before checking file existence when loading any MangoHud configuration.

#### Scenario: Loading MangoHud configuration file when file is missing
- **WHEN** the system attempts to load a MangoHud configuration file that does not exist
- **THEN** it SHALL execute `ResetMangoHudControls` first to clear all previous control states before exiting.
