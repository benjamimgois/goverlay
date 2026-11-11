# Spec Delta

## MODIFIED Requirements

### Requirement: First-Launch Onboarding Wizard Display
The system SHALL present a modular onboarding dialog on the first application launch when `FirstRunWizardCompleted` is not set to true, allowing users to toggle optional component ecosystems.

#### Scenario: First application launch
- **WHEN** Goverlay starts and `FirstRunWizardCompleted` is false or not present in `goverlay.conf`
- **THEN** the system displays the modular onboarding dialog before proceeding to the main window.

#### Scenario: User accepts custom selection
- **WHEN** the user selects or deselects modules in the onboarding dialog and clicks "Save and Continue"
- **THEN** the system persists the selections to `goverlay.conf`, marks `FirstRunWizardCompleted` as true, and initializes only the enabled modules.

#### Scenario: User chooses minimal configuration
- **WHEN** the user leaves all optional modules deselected and clicks "Save and Continue"
- **THEN** the system sets all optional modules to false, marks `FirstRunWizardCompleted` as true, and starts immediately without downloading external runtimes.

#### Scenario: User selects or deselects all optional modules
- **WHEN** the user clicks "Select All" (or "Deselect All" when all optional modules are enabled)
- **THEN** the system toggles all optional modules simultaneously, keeping MangoHud locked active, and updates category and footer active counters.

### Requirement: Integrations and Modules Manager in Settings Menu
The system SHALL provide a settings menu entry to open the module configuration manager at any time.

#### Scenario: Opening module manager from settings menu
- **WHEN** the user clicks the settings button (☰) and chooses "Manage Integrations / Modules"
- **THEN** the system opens the module selection dialog displaying "Manage Integrations and Modules" with a "Save and Apply" primary action button, allowing the user to enable or disable modules and apply changes.

## ADDED Requirements

### Requirement: Modern Component Setup Visual Presentation and Theme Compliance
The Component Setup dialog SHALL render module cards using left-aligned textless toggle switches, interactive hover/active borders, category active counters, GOverlay's modern app icon in the header, a `6px` thin modern scrollbar, and theme-aware Dark/Light colors matching GOverlay's visual design system without clipping header text or cards at the scroll fold.

#### Scenario: Rendering module cards and core badge
- **WHEN** the Component Setup dialog opens
- **THEN** the header displays GOverlay's modern app icon alongside the title, and each module card displays a left-aligned textless toggle switch, title, and description, with MangoHud displaying a green "Core" pill badge and locked active state.

#### Scenario: Interactive state feedback and counters
- **WHEN** the user hovers over or toggles any optional module card
- **THEN** the card updates its hover/active border and accent strip, synchronizes its toggle switch and category active counter pill (e.g., "1 / 3 active"), and updates the footer total counter ("X of 10 active").

#### Scenario: Dark and Light theme coherence
- **WHEN** GOverlay is running in Dark mode or Light mode (`CurrentTheme`)
- **THEN** the Component Setup dialog adapts window, header, footer, card, text, pill, and scrollbar colors to match the active GOverlay theme.
