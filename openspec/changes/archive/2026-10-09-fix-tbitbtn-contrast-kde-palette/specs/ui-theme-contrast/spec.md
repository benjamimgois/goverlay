# Spec Delta

## MODIFIED Requirements

### Requirement: Shortcut capture button contrast
The system SHALL render key capture buttons with consistent foreground text and background colors matching the active GOverlay theme across all tabs by explicitly synchronizing both Qt stylesheets and the underlying widget palette.

#### Scenario: Key capture buttons under hybrid or light desktop theme
- **WHEN** the user inspects HUD Toggle Key, Limit toggle key, or Logging toggle key under a hybrid or light desktop theme
- **THEN** the buttons render readable white text over their styled background rather than inheriting the system desktop's dark text color

### Requirement: Columns stepper buttons contrast
The system SHALL render the plus and minus column stepper buttons with explicit foreground text colors matching the active GOverlay theme by synchronizing the Qt widget palette ButtonText and WindowText roles alongside the stylesheet.

#### Scenario: Columns stepper buttons display
- **WHEN** the user views the Columns panel in the Visual tab
- **THEN** the minus and plus button symbols are clearly legible with high contrast against the button background

## ADDED Requirements

### Requirement: TBitBtn controls palette synchronization across cards and tabs
The system SHALL ensure all `TBitBtn` controls across all tabs (including Metrics toggles `gpuframesjouleBitBtn`, `coreloadtypeBitBtn`, `cpuframesjouleBitBtn`, Performance toggles `fpsavgBitBtn`, `frametimetypeBitBtn`, and generic card buttons) synchronize their underlying Qt palette `QPaletteButtonText` and `QPaletteWindowText` roles to match the active GOverlay theme text color.

#### Scenario: Metrics toggle buttons under hybrid KDE theme
- **WHEN** the user views the Metrics tab under Kubuntu or KDE Breeze Light/Hybrid desktop theme
- **THEN** toggle buttons such as "Frames / Joule", "% Percent", and "1% low" display high-contrast white text matching the dark card theme

#### Scenario: Generic cards refreshed with active theme
- **WHEN** generic cards containing `TBitBtn` controls are rendered or refreshed via `UpdateGenericCardTheme`
- **THEN** each contained `TBitBtn` receives both explicit stylesheet rules and Qt palette synchronization
