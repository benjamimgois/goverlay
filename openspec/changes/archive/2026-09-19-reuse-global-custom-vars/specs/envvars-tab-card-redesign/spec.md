# Spec Delta

## ADDED Requirements

### Requirement: Global Custom Variables Persistence
The EnvVars tab SHALL persist all custom environment variables defined in Global mode in `bgmod.conf` across both enabled (toggle ON) and disabled (toggle OFF) states, retaining them in a dedicated `[CustomVariables]` section so that disabled variables are not lost on reload or application restart.

#### Scenario: Disabling a global custom variable
- **WHEN** user toggles off a custom variable in Global mode
- **THEN** the variable is removed from the active `[Env]` section but preserved in the `[CustomVariables]` section of the global `bgmod.conf`, remaining visible with toggle OFF upon reload.

#### Scenario: Re-enabling a disabled global custom variable
- **WHEN** user toggles on a previously disabled custom variable in Global mode
- **THEN** the variable is written to the active `[Env]` section and preserved in `[CustomVariables]`.

#### Scenario: Deleting a global custom variable
- **WHEN** user clicks the delete button (`×`) on a custom variable in Global mode
- **THEN** the variable is removed from both `[Env]` and `[CustomVariables]` sections and disappears from the list.

### Requirement: Per-Game Catalog Inheritance for Custom Variables
When viewing the EnvVars tab for an active game profile, the Custom Variables card SHALL display all custom variables defined in the Global catalog alongside any game-specific custom variables. Global variables SHALL appear with toggle OFF by default unless explicitly enabled in the active game profile's configuration.

#### Scenario: Viewing custom variables in a new game profile
- **WHEN** user selects a game profile and opens the EnvVars tab
- **THEN** all global custom variables are rendered in the Custom Variables card with their toggle switches set to OFF (unless previously enabled for that game).

#### Scenario: Enabling a global custom variable for a specific game
- **WHEN** user toggles on a global custom variable within a game profile
- **THEN** the variable switch changes to ON, and the variable is saved to the active game profile's `bgmod.conf` `[Env]` section without altering the global catalog or other game profiles.

#### Scenario: Disabling a global custom variable for a specific game
- **WHEN** user toggles off an enabled global custom variable within a game profile
- **THEN** the variable switch changes to OFF, and the variable is removed from the game's `bgmod.conf` `[Env]` section while remaining visible as an available option in the Custom Variables card.

### Requirement: Visual Distinction and Deletion Protection in Game Profiles
The Custom Variables card SHALL visually distinguish inherited global variables from game-specific local variables using a `[Global]` badge chip, and SHALL guard global entries against accidental deletion from within game profiles.

#### Scenario: Distinguishing global vs game-specific variables
- **WHEN** custom variables are rendered within a game profile
- **THEN** global variables display a compact `[Global]` badge chip, while local variables display standard local styling.

#### Scenario: Deletion guard for global variables in game profiles
- **WHEN** user views global variables in a game profile
- **THEN** no delete button (`×`) is shown or operable for global catalog entries, preventing accidental deletion of the global preset from within a single game context.

#### Scenario: Deleting a game-specific custom variable
- **WHEN** user clicks the delete button (`×`) on a local custom variable created in that game profile
- **THEN** the local variable is removed from the game profile's configuration and UI list.
