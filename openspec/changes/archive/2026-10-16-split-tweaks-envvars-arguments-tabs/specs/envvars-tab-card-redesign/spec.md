# Spec Delta: envvars-tab-card-redesign

## ADDED Requirements

### Requirement: Tweaks Sub-Tab Navigation for EnvVars and Arguments
Selecting Tweaks from the sidebar navigation rail SHALL display a secondary tab navigation bar with two sub-tabs: "EnvVars" and "Arguments". The EnvVars sub-tab SHALL display the environment variable category cards, while the Arguments sub-tab SHALL display the launch arguments cards.

#### Scenario: Navigating to Tweaks from sidebar
- **WHEN** user clicks on the "Tweaks" item in the sidebar navigation rail
- **THEN** the secondary tab control becomes visible with two sub-tabs labeled "EnvVars" and "Arguments".

#### Scenario: Switching between EnvVars and Arguments sub-tabs
- **WHEN** user clicks on the "Arguments" sub-tab
- **THEN** the view switches to display the launch arguments cards, and switching back to "EnvVars" displays the environment variables cards.

## MODIFIED Requirements

### Requirement: Dedicated Launch Arguments Card
The Tweaks section SHALL render launch arguments within a dedicated "Arguments" sub-tab rather than on the EnvVars canvas. The Arguments sub-tab SHALL be organized into two distinct cards: "Predefined Arguments" and "Custom Arguments", matching standard GOverlay card styling with 4px margins and responsive layout.

#### Scenario: Navigating to the EnvVars tab
- **WHEN** user scrolls through the EnvVars tab
- **THEN** only environment variable categories are displayed, and launch arguments are accessed via the dedicated Arguments sub-tab.

#### Scenario: Navigating to the Arguments sub-tab
- **WHEN** user navigates to the "Arguments" sub-tab within Tweaks
- **THEN** two distinct cards are displayed: "Predefined Arguments" containing curated options, and "Custom Arguments" containing user-added arguments.

### Requirement: Predefined Curated Launch Arguments
The Predefined Arguments card on the Arguments sub-tab SHALL include predefined toggle items for common Linux gaming arguments, specifically:
- `-novid` (Skip intro videos and logos)
- `-vulkan` (Force native Vulkan renderer)
- `-dx11` (Force DirectX 11 backend)
- `-dx12` (Force DirectX 12 backend)
- `-nojoy` (Disable joystick subsystem)

#### Scenario: Toggling a predefined launch argument
- **WHEN** user clicks on the `-novid` toggle switch in the Predefined Arguments card
- **THEN** the switch toggles to ON, and `-novid` is marked for inclusion in the game launch arguments.

### Requirement: Automatic Input Routing for + Add Action
The floating `+ Add` button SHALL open contextually based on the active sub-tab:
- When on the `EnvVars` sub-tab, the Add dialog SHALL open focused for adding an environment variable and validate `KEY=VALUE` formatting.
- When on the `Arguments` sub-tab, the Add dialog SHALL open focused for adding a launch argument and validate launch argument formatting (starting with `-`, `--`, or `+`).

#### Scenario: Adding a launch option argument
- **WHEN** user clicks `+ Add` while on the Arguments sub-tab and enters `+fps_max 0`
- **THEN** `+fps_max 0` is added as a new row in the Custom Arguments card with toggle ON.

#### Scenario: Adding an environment variable
- **WHEN** user clicks `+ Add` while on the EnvVars sub-tab and enters `ENABLE_FEATURE=1`
- **THEN** `ENABLE_FEATURE=1` is added as a new row in the Custom Variables card with toggle ON.

### Requirement: Per-Game Catalog Inheritance and Deletion Guard for Arguments
Custom launch arguments defined in Global mode SHALL be inherited into game profiles with toggle switch set to OFF by default in the Custom Arguments card. Inherited global arguments SHALL display a `[Global]` badge chip and suppress the delete (`×`) button in game profiles, while local arguments created within a game profile SHALL display a `[Game]` badge chip and allow deletion.

#### Scenario: Viewing global arguments in a new game profile
- **WHEN** user opens the Arguments sub-tab in a game profile
- **THEN** all global custom arguments appear in the Custom Arguments card with toggle OFF and a `[Global]` badge chip.

#### Scenario: Attempting to delete a global argument from a game profile
- **WHEN** user attempts to delete an inherited global argument inside a game profile
- **THEN** deletion is prevented and the global catalog entry remains intact.

### Requirement: Contextual Catalog Info Chip Banner for Custom and Argument Sections
A dedicated Info Chip banner SHALL render immediately before the Custom Variables card in the EnvVars sub-tab, and immediately before the Custom Arguments card in the Arguments sub-tab, to clearly communicate global catalog persistence and per-game profile inheritance without cluttering card headers.

#### Scenario: Info banner in Global mode
- **WHEN** viewing either the EnvVars or Arguments sub-tab in Global mode
- **THEN** an Info Chip banner displays: *"Custom items added in Global mode are cataloged and can be toggled per game."*

#### Scenario: Info banner in Per-Game profile mode
- **WHEN** viewing either the EnvVars or Arguments sub-tab in a specific game profile
- **THEN** an Info Chip banner displays: *"Global catalog items are listed below. Toggling applies only to this game."*
