# global-sidebar-toggles

This capability implements ON/OFF toggles in the navigation sidebar for global configuration profiles, ensuring consistency with game-specific configuration behaviors.

## Requirements

### Requirement: Toggle visibility in navigation sidebar
The system SHALL display the tool toggles in the navigation sidebar only when the user is inside a tool configuration page (either global mode or game-specific mode) and hide them when the user is on the "Games" landing tab.

#### Scenario: Navigating to the Games tab
- **WHEN** the user navigates to the Games tab
- **THEN** the system hides all sidebar tool toggles

#### Scenario: Navigating to a tool configuration tab
- **WHEN** the user navigates to any tool configuration tab (such as MangoHud or vkBasalt) in either global or game-specific mode
- **THEN** the system shows the sidebar tool toggles

### Requirement: Global tool toggling logic
The system SHALL support turning tool configurations ON or OFF globally via the sidebar toggles. Turning a tool OFF globally SHALL disable all associated input fields in the UI and delete its global configuration file. Turning a tool ON globally SHALL enable the associated inputs and immediately populate/synchronize required tool configuration files and DLLs into `gameconfig/global/`.

#### Scenario: Toggling a tool OFF globally
- **WHEN** the user clicks a sidebar tool toggle to set it to OFF while in global mode
- **THEN** the system disables the tab sheets and inputs for that tool
- **AND** it deletes the global configuration file for that tool

#### Scenario: Toggling a tool ON globally
- **WHEN** the user clicks a sidebar tool toggle to set it to ON while in global mode
- **THEN** the system enables the tab sheets and inputs for that tool, allowing customization and saving

#### Scenario: Toggling OptiScaler ON globally
- **WHEN** the user clicks the OptiScaler sidebar tool toggle to set it to ON while in global mode (`FActiveGameName = ''`)
- **THEN** the system enables the OptiScaler tab sheets and inputs
- **AND** it immediately populates and synchronizes OptiScaler configuration files and DLLs into `gameconfig/global/` without requiring a manual save or driver selection change.

### Requirement: Explicit Target Config Path Assignment on Sidebar Tab Navigation
GOverlay SHALL explicitly set `MANGOHUDCFGFILE`, `VKBASALTCFGFILE`, and `VKSUMICFGFILE` to global profile directory paths when navigating to sidebar tabs in global mode (`FActiveGameName = ''`).

#### Scenario: Navigating to MangoHud or vkBasalt tab in global mode
- **WHEN** `FActiveGameName` is empty and the user clicks on the MangoHud or vkBasalt sidebar tab
- **THEN** GOverlay SHALL assign `MANGOHUDCFGFILE`, `VKBASALTCFGFILE`, and `VKSUMICFGFILE` to their respective global config paths before reloading tab settings.
