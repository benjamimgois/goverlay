## Purpose

Provides a unified, modern floating action dock (pill-style bar) anchored in the bottom-right corner of GOverlay, hosting contextual quick-action buttons across all configuration tabs.

## ADDED Requirements

### Requirement: Floating Action Dock Rendering and Positioning
The system SHALL display a floating action pill dock anchored at the bottom-right corner of the main content area, rendered with rounded pill borders, subtle elevation, and a dark translucent background.

#### Scenario: Displaying floating action dock
- **WHEN** GOverlay main window is displayed
- **THEN** the floating action dock SHALL be anchored at the bottom-right above tab content without being obscured by page elements.

### Requirement: Contextual Action Buttons in Dock
The system SHALL present action controls within the floating action dock according to the capabilities of the currently active tab.

#### Scenario: Viewing tabs with 3D overlay support
- **WHEN** user is on MangoHud, vkBasalt, or vkSumi tabs
- **THEN** the dock SHALL display the 3D Preview button (`▶`), the Menu button (`☰`), and the primary Finish Config button (`Finish Config`).

#### Scenario: Viewing tabs without 3D overlay support
- **WHEN** user is on OptiScaler or EnvVars tabs
- **THEN** the dock SHALL hide the 3D Preview button (`▶`) and adjust its compact pill width while keeping the Menu button (`☰`) and the Finish Config button (`Finish Config`) visible.

### Requirement: Action Button Interactions
The system SHALL execute corresponding workflows when floating dock buttons are clicked.

#### Scenario: Clicking Preview button
- **WHEN** user clicks the Preview button in the floating dock
- **THEN** GOverlay SHALL launch the 3D preview benchmark (pascube or vkcube) according to the configured overlay settings.

#### Scenario: Clicking Menu button
- **WHEN** user clicks the Menu button in the floating dock
- **THEN** GOverlay SHALL display the contextual options popup menu for the active tab.

#### Scenario: Clicking Finish Config button
- **WHEN** user clicks the Finish Config button in the floating dock
- **THEN** GOverlay SHALL open the Finish Configuration and Launch Setup dialog.
