# Spec Delta

## Purpose

Provides a first-launch modular onboarding experience, persistent module activation settings, a settings menu module manager, and on-demand activation placeholder cards for optional Goverlay features.

## ADDED Requirements

### Requirement: First-Launch Onboarding Wizard Display
The system SHALL present a modular onboarding dialog on the first application launch when `FirstRunWizardCompleted` is not set to true, allowing users to toggle optional component ecosystems.

#### Scenario: First application launch
- **WHEN** Goverlay starts and `FirstRunWizardCompleted` is false or not present in `goverlay.conf`
- **THEN** the system displays the modular onboarding dialog before proceeding to the main window.

#### Scenario: User accepts custom selection
- **WHEN** the user selects or deselects modules in the onboarding dialog and clicks "Confirm"
- **THEN** the system persists the selections to `goverlay.conf`, marks `FirstRunWizardCompleted` as true, and initializes only the enabled modules.

#### Scenario: User chooses minimal configuration
- **WHEN** the user clicks "Keep MangoHud Only"
- **THEN** the system sets all optional modules to false, marks `FirstRunWizardCompleted` as true, and starts immediately without downloading external runtimes.

### Requirement: Module Preference Persistence and Initial Migration
The system SHALL persist module enablement states under the `[Modules]` section of `goverlay.conf` and provide seamless automatic migration for existing installations.

#### Scenario: Existing installation detection
- **WHEN** Goverlay starts and detects an existing configuration where `FirstRunWizardCompleted` is not explicitly set but core libraries already exist
- **THEN** the system marks `FirstRunWizardCompleted` as true and sets existing modules to enabled, avoiding an unexpected popup for existing active users.

#### Scenario: Reading saved module preferences
- **WHEN** Goverlay starts on subsequent launches
- **THEN** the system reads `PostProcessing`, `Upscalers`, and `FrameGeneration` booleans from `goverlay.conf` to determine active feature sets.

### Requirement: On-Demand Activation Cards for Disabled Tabs
The system SHALL keep all navigation tabs accessible in the sidebar and display an on-demand activation card with an enable button whenever the user navigates to a tab whose module is disabled.

#### Scenario: Navigating to a disabled module tab
- **WHEN** the user selects the "Upscalers" or "Frame Interpolation" tab and the corresponding module is disabled
- **THEN** the system displays a themed placeholder card explaining the feature with an "Enable & Download Components" action button.

#### Scenario: Activating a module from a placeholder card
- **WHEN** the user clicks "Enable & Download Components" on a disabled tab placeholder card
- **THEN** the system enables the module in `goverlay.conf`, triggers the necessary component downloads, and unlocks the tab's full configuration controls.

### Requirement: Integrations and Modules Manager in Settings Menu
The system SHALL provide a settings menu entry to open the module configuration manager at any time.

#### Scenario: Opening module manager from settings menu
- **WHEN** the user clicks the settings button (☰) and chooses "Manage Integrations / Modules"
- **THEN** the system opens the module selection dialog allowing the user to enable or disable modules and apply changes.
