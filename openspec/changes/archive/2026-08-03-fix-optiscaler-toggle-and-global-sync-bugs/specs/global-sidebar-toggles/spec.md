# global-sidebar-toggles Delta Spec

## MODIFIED REQUIREMENTS

### Requirement: Global tool toggling logic
The system SHALL support turning tool configurations ON or OFF globally via the sidebar toggles. Turning a tool OFF globally SHALL disable all associated input fields in the UI and delete its global configuration file. Turning a tool ON globally SHALL enable the associated inputs and immediately populate/synchronize required tool configuration files and DLLs into `gameconfig/global/`.

#### Scenario: Toggling OptiScaler ON globally
- **WHEN** the user clicks the OptiScaler sidebar tool toggle to set it to ON while in global mode (`FActiveGameName = ''`)
- **THEN** the system enables the OptiScaler tab sheets and inputs
- **AND** it immediately populates and synchronizes OptiScaler configuration files and DLLs into `gameconfig/global/` without requiring a manual save or driver selection change.
