# ui-theme-contrast Specification

## Purpose
Ensures all controls, buttons, and selection inputs maintain legible text contrast against their backgrounds regardless of the desktop environment theme (including hybrid and light KDE Plasma themes).

## Requirements

### Requirement: Filter radio buttons text contrast
The system SHALL display filter radio button labels with explicit high-contrast text color against the card background across all desktop environment styles.

#### Scenario: Filter radio buttons under dark theme
- **WHEN** GOverlay runs in dark theme or under a hybrid light/dark desktop theme
- **THEN** radio button labels in the Filters card (None, Bicubic, Trilinear, Retro) are rendered with white readable text against the dark card background

#### Scenario: Filter radio buttons under light theme
- **WHEN** GOverlay runs in light theme
- **THEN** radio button labels in the Filters card are rendered with dark readable text against the light card background

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

### Requirement: Selection controls in generic cards
The system SHALL ensure both checkboxes and radio buttons in generic card containers maintain theme-appropriate foreground colors.

#### Scenario: Radio buttons inside generic cards
- **WHEN** a card container containing radio buttons is refreshed with the active theme
- **THEN** all radio buttons inside the container receive explicit text color styling matching the container theme

### Requirement: TBitBtn controls palette synchronization across cards and tabs
The system SHALL ensure all `TBitBtn` controls across all tabs (including Metrics toggles `gpuframesjouleBitBtn`, `coreloadtypeBitBtn`, `cpuframesjouleBitBtn`, Performance toggles `fpsavgBitBtn`, `frametimetypeBitBtn`, and generic card buttons) synchronize their underlying Qt palette `QPaletteButtonText` and `QPaletteWindowText` roles to match the active GOverlay theme text color.

#### Scenario: Metrics toggle buttons under hybrid KDE theme
- **WHEN** the user views the Metrics tab under Kubuntu or KDE Breeze Light/Hybrid desktop theme
- **THEN** toggle buttons such as "Frames / Joule", "% Percent", and "1% low" display high-contrast white text matching the dark card theme

#### Scenario: Generic cards refreshed with active theme
- **WHEN** generic cards containing `TBitBtn` controls are rendered or refreshed via `UpdateGenericCardTheme`
- **THEN** each contained `TBitBtn` receives both explicit stylesheet rules and Qt palette synchronization
