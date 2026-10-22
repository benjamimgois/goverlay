# Spec Delta: envvars-tab-card-redesign

## ADDED Requirements

### Requirement: Sidebar Navigation Tab Labeling as Tweaks
The sidebar navigation rail SHALL display the tab caption as "Tweaks", accurately reflecting its combination of environment variables, launch arguments, and performance command wrappers.

#### Scenario: Displaying Tweaks tab in sidebar navigation
- **WHEN** the main window is rendered with the sidebar navigation rail
- **THEN** the fifth navigation item displays the gear icon alongside the caption "Tweaks".

### Requirement: Contextual Catalog Info Chip Banner for Custom and Argument Sections
A dedicated Info Chip banner SHALL render immediately before the Custom Variables and Launch Arguments cards to clearly communicate global catalog persistence and per-game profile inheritance without cluttering card headers.

#### Scenario: Info banner in Global mode
- **WHEN** viewing the Tweaks tab in Global mode
- **THEN** an Info Chip banner displays: *"Custom items added in Global mode are cataloged and can be toggled per game."*

#### Scenario: Info banner in Per-Game profile mode
- **WHEN** viewing the Tweaks tab in a specific game profile
- **THEN** an Info Chip banner displays: *"Global catalog items are listed below. Toggling applies only to this game."*
