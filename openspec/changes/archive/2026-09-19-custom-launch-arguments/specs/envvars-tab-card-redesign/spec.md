# Spec Delta

## ADDED Requirements

### Requirement: Dedicated Launch Arguments Card
The EnvVars tab SHALL render a dedicated "Launch Arguments" themed card placed directly below the Custom Variables card, following standard GOverlay card styling with 4px margins and a responsive two-column grid layout.

#### Scenario: Navigating to the EnvVars tab
- **WHEN** user scrolls through the EnvVars tab
- **THEN** both the "Custom Variables" card and the "Launch Arguments" card are displayed with category headers, active item counters, and toggle items.

### Requirement: Predefined Curated Launch Arguments
The Launch Arguments card SHALL include predefined toggle items for common Linux gaming arguments, specifically:
- `-novid` (Skip intro videos and logos)
- `-vulkan` (Force native Vulkan renderer)
- `-dx11` (Force DirectX 11 backend)
- `-dx12` (Force DirectX 12 backend)
- `-nojoy` (Disable joystick subsystem)

#### Scenario: Toggling a predefined launch argument
- **WHEN** user clicks on the `-novid` toggle switch
- **THEN** the switch toggles to ON, and `-novid` is marked for inclusion in the game launch arguments.

### Requirement: Automatic Input Routing for + Add Action
The floating `+ Add` button SHALL automatically classify user input:
- If the trimmed input starts with `-`, `--`, or `+`, it SHALL be added as a launch argument to the Launch Arguments card.
- If the trimmed input does not start with those prefixes (or contains `=`), it SHALL be added as an environment variable to the Custom Variables card.

#### Scenario: Adding a launch option argument
- **WHEN** user enters `+fps_max 0` into the `+ Add` prompt
- **THEN** `+fps_max 0` is added as a new row in the Launch Arguments card with toggle ON.

#### Scenario: Adding an environment variable
- **WHEN** user enters `ENABLE_FEATURE=1` into the `+ Add` prompt
- **THEN** `ENABLE_FEATURE=1` is added as a new row in the Custom Variables card with toggle ON.

### Requirement: Launch Arguments Persistence and Runner Injection
Active launch arguments SHALL be saved in an `[Args]` section in `bgmod.conf`. In Global mode, all custom arguments SHALL be retained in a `[CustomArguments]` section regardless of toggle state. The `bgmod` wrapper binary SHALL read `[Args]` from `bgmod.conf` and inject enabled argument strings into the command argument array passed to the game executable via `execvpe`.

#### Scenario: Saving active launch arguments
- **WHEN** user enables `-vulkan` and `+fps_max 0` and saves configuration
- **THEN** `bgmod.conf` contains `-vulkan=1` and `+fps_max 0=1` under `[Args]`.

#### Scenario: Executing game with active launch arguments
- **WHEN** `bgmod` launches a game with active arguments in `[Args]`
- **THEN** `bgmod` appends the active arguments to the subprocess execution argument vector before invoking `execvpe`.

### Requirement: Per-Game Catalog Inheritance and Deletion Guard for Arguments
Custom launch arguments defined in Global mode SHALL be inherited into game profiles with toggle switch set to OFF by default. Inherited global arguments SHALL display a `[Global]` badge chip and suppress the delete (`×`) button in game profiles, while local arguments created within a game profile SHALL display a `[Game]` badge chip and allow deletion.

#### Scenario: Viewing global arguments in a new game profile
- **WHEN** user opens the EnvVars tab in a game profile
- **THEN** all global custom arguments appear in the Launch Arguments card with toggle OFF and a `[Global]` badge chip.

#### Scenario: Attempting to delete a global argument from a game profile
- **WHEN** user attempts to delete an inherited global argument inside a game profile
- **THEN** deletion is prevented and the global catalog entry remains intact.
