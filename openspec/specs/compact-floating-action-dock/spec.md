# compact-floating-action-dock Specification

## Purpose
Provides a unified, compact floating action dock hosting contextual quick actions across all configuration tabs (including custom environment variable creation on EnvVars) alongside the primary Finish action.

## Requirements

### Requirement: Unified EnvVars Action in Dock
The system SHALL present an integrated `+ Add` button inside the floating action dock when viewing the EnvVars (Tweaks) tab, replacing the separate floating button.

#### Scenario: Viewing EnvVars tab
- **WHEN** user switches to the EnvVars tab
- **THEN** GOverlay SHALL display a unified dock containing the secondary `+ Add` button and the primary `✦ Finish` button.

#### Scenario: Clicking Add button in dock
- **WHEN** user clicks the `+ Add` button within the floating action dock on the EnvVars tab
- **THEN** GOverlay SHALL open the custom environment variable addition dialog.

### Requirement: Compact Pill Geometry and Accent Hierarchy
The system SHALL render the floating action dock with compact dimensions (total height <= 40px) and apply the cyan accent color exclusively to the primary `✦ Finish` action button.

#### Scenario: Viewing multi-button dock
- **WHEN** the floating action dock displays multiple actions (e.g. Preview + Menu + Finish or Add + Finish)
- **THEN** secondary buttons SHALL render with dark neutral styling, and only the `✦ Finish` button SHALL render with the cyan accent highlight.

#### Scenario: Viewing solo Finish dock
- **WHEN** the dock contains only the `✦ Finish` button (e.g. on the Upscalers tab)
- **THEN** the entire pill SHALL be filled with the cyan accent color and compact width (~84px).
