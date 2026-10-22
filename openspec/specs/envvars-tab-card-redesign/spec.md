# envvars-tab-card-redesign Specification

## Purpose
Provides a clean, card-based interface with refined toggle controls for managing environment variables and Proton/Wine compatibility tweaks in GOverlay.

## Requirements

### Requirement: Card-Based Grouped Layout for EnvVars
The EnvVars tab SHALL organize environment variables and tweaks into distinct themed cards (`General`, `Graphics`, `Performance`, `Latency reduction`, `Experimental`, and `Custom Variables`) using standard GOverlay card background and border styling. All category cards SHALL span across nearly the entire horizontal client width with a 4px margin on both sides (`Left = 4`, `Right = ClientWidth - 4`), matching the standard geometry of Lossless Scaling.

#### Scenario: Viewing EnvVars tab categories
- **WHEN** the user navigates to the EnvVars tab
- **THEN** the settings are displayed within structured dark cards with clear category headers, including `General`, `Graphics`, `Performance`, `Latency reduction`, and `Experimental`, spanning from `Left = 4` to `Right = ClientWidth - 4` with uniform 4px side margins.

#### Scenario: Resizing window with EnvVars tab active
- **WHEN** the user resizes the application window
- **THEN** the EnvVars category cards and their two-column item layouts dynamically adapt to fill the available width while maintaining the 4px side margins.

### Requirement: Refined Toggle Switches
The EnvVars tab SHALL provide refined toggle switches for enabling and disabling environment variables, matching the application dark theme palette and visual state conventions.

#### Scenario: Toggling a variable switch
- **WHEN** the user clicks on a tweak or variable item row or its toggle switch
- **THEN** the switch state transitions between enabled and disabled with smooth visual feedback, and the underlying configuration is updated.

### Requirement: Compact Badge Chips for Special Prefixes
The EnvVars tab SHALL display compatibility tags (such as `[CachyOS]`, `[MESA]`, and `[LowLatency]`) as compact, rounded badge chips alongside the tweak description.

#### Scenario: Rendering items with vendor or layer tags
- **WHEN** an environment variable option has an associated prefix or tag
- **THEN** the tag is rendered as a clean badge chip distinct from the main descriptive label.

### Requirement: Scroll Safety and Floating Dock Integration
The EnvVars tab SHALL preserve the global floating action dock (`[ ☰ ] [ + Add ] [ ✓ Finish ]`) while maintaining sufficient bottom padding so that no setting rows are covered when scrolled to the end.

#### Scenario: Scrolling to the bottom of the EnvVars list
- **WHEN** the user scrolls down to the end of the EnvVars tab
- **THEN** the final settings and custom variables remain fully visible and clickable above the floating dock.

### Requirement: Disabled State Styling and Interaction Guard for Conflicting Toggles
The EnvVars tab SHALL visually represent disabled tweak toggles with dimmed/muted styling, block mouse interaction, and display explanatory tooltip feedback when hovered.

#### Scenario: Rendering disabled toggles
- **WHEN** a tweak toggle (such as "Enable Wayland" or "Enable HDR") is disabled due to MAKO being active
- **THEN** the toggle track and thumb are drawn in a dimmed gray style and item text is dimmed to clearly convey the disabled state.

#### Scenario: User attempts to click a disabled toggle
- **WHEN** user clicks on a disabled toggle item in the EnvVars tab
- **THEN** the click is ignored, the toggle state does not change, and the underlying configuration remains unchanged.

#### Scenario: User hovers over a disabled toggle
- **WHEN** user hovers the mouse cursor over a disabled toggle row
- **THEN** the tooltip or status bar displays an explanatory message indicating that the option is disabled due to MAKO incompatibility.

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

### Requirement: Launch Arguments Persistence and Runner Injection
Active launch arguments SHALL be saved in an `[Args]` section in `bgmod.conf`. In Global mode, all custom arguments SHALL be retained in a `[CustomArguments]` section regardless of toggle state. The `bgmod` wrapper binary SHALL read `[Args]` from `bgmod.conf` and inject enabled argument strings into the command argument array passed to the game executable via `execvpe`.

#### Scenario: Saving active launch arguments
- **WHEN** user enables `-vulkan` and `+fps_max 0` and saves configuration
- **THEN** `bgmod.conf` contains `-vulkan=1` and `+fps_max 0=1` under `[Args]`.

#### Scenario: Executing game with active launch arguments
- **WHEN** `bgmod` launches a game with active arguments in `[Args]`
- **THEN** `bgmod` appends the active arguments to the subprocess execution argument vector before invoking `execvpe`.

### Requirement: Per-Game Catalog Inheritance and Deletion Guard for Arguments
Custom launch arguments defined in Global mode SHALL be inherited into game profiles with toggle switch set to OFF by default in the Custom Arguments card. Inherited global arguments SHALL display a `[Global]` badge chip and suppress the delete (`×`) button in game profiles, while local arguments created within a game profile SHALL display a `[Game]` badge chip and allow deletion.

#### Scenario: Viewing global arguments in a new game profile
- **WHEN** user opens the Arguments sub-tab in a game profile
- **THEN** all global custom arguments appear in the Custom Arguments card with toggle OFF and a `[Global]` badge chip.

#### Scenario: Attempting to delete a global argument from a game profile
- **WHEN** user attempts to delete an inherited global argument inside a game profile
- **THEN** deletion is prevented and the global catalog entry remains intact.

### Requirement: Sidebar Navigation Tab Labeling as Tweaks
The sidebar navigation rail SHALL display the tab caption as "Tweaks", accurately reflecting its combination of environment variables, launch arguments, and performance command wrappers.

#### Scenario: Displaying Tweaks tab in sidebar navigation
- **WHEN** the main window is rendered with the sidebar navigation rail
- **THEN** the fifth navigation item displays the gear icon alongside the caption "Tweaks".

### Requirement: Contextual Catalog Info Chip Banner for Custom and Argument Sections
A dedicated Info Chip banner SHALL render immediately before the Custom Variables card in the EnvVars sub-tab, and immediately before the Custom Arguments card in the Arguments sub-tab, to clearly communicate global catalog persistence and per-game profile inheritance without cluttering card headers.

#### Scenario: Info banner in Global mode
- **WHEN** viewing either the EnvVars or Arguments sub-tab in Global mode
- **THEN** an Info Chip banner displays: *"Custom items added in Global mode are cataloged and can be toggled per game."*

#### Scenario: Info banner in Per-Game profile mode
- **WHEN** viewing either the EnvVars or Arguments sub-tab in a specific game profile
- **THEN** an Info Chip banner displays: *"Global catalog items are listed below. Toggling applies only to this game."*

### Requirement: Dedicated Experimental Tweaks Card with Warning Banner
The EnvVars tab SHALL render a dedicated "Experimental" category card containing cutting-edge compatibility tweaks. The card header SHALL render in prominent amber/gold styling with a warning icon (`⚠ Experimental`), and a prominent warning banner SHALL render inside the card above its toggles, stating that experimental options may cause instability or visual artifacts and should only be enabled when required by specific titles.

#### Scenario: Viewing the Experimental card
- **WHEN** the user scrolls to the Experimental card in the Tweaks tab
- **THEN** the card renders with an amber header, active count badge, and a top-anchored amber warning banner explaining that experimental tweaks are intended for bleeding-edge game compatibility and may cause instability.

#### Scenario: Hovering over an experimental tweak toggle
- **WHEN** the user hovers over any toggle row inside the Experimental card
- **THEN** the tooltip displays the option's specific function alongside an explicit experimental warning note.

### Requirement: Bleeding-Edge Compatibility Variables in Experimental Card
The Experimental card SHALL provide toggles for cutting-edge DirectX 12 and Ray Tracing Proton/Wine compatibility options, specifically:
- **Descriptor Heap**: bundles `VKD3D_CONFIG=descriptor_heap` and `PROTON_VKD3D_HEAP=1` under a single toggle switch to fix crashes and freezes in titles requiring alternative descriptor heap paths (such as *Control Resonant*).
- **Ray Reconstruction**: sets `NGX_DLSS_RR_OVERRIDE=on` to force DLSS Ray Reconstruction on supported Nvidia titles, rendered with a green `[NVIDIA]` badge chip.
- **RT Acceleration Structures Multiplier**: sets `VKD3D_RTAS_SIZE_MULT=8` to expand RT acceleration structure buffer allocations.
- **Zink Renderer**: sets `MESA_LOADER_DRIVER_OVERRIDE=zink`, migrated from the Graphics card with a `[MESA]` badge chip.
- **RE Engine RT Workaround**: sets `#winedetectionenable=false`, migrated from the Graphics card.

All five options SHALL be recognized by the predefined environment variable classifier so that none of them leak into the Custom Variables list.

#### Scenario: Toggling Descriptor Heap support
- **WHEN** the user enables the Descriptor Heap toggle in the Experimental card and saves
- **THEN** both `VKD3D_CONFIG=descriptor_heap` and `PROTON_VKD3D_HEAP=1` are written to the `[Env]` section of `bgmod.conf`.

#### Scenario: Toggling Ray Reconstruction override
- **WHEN** the user enables the Ray Reconstruction toggle and saves
- **THEN** `NGX_DLSS_RR_OVERRIDE=on` is written to `[Env]` in `bgmod.conf` and the item displays a green `[NVIDIA]` badge chip.

#### Scenario: Toggling RTAS size multiplier
- **WHEN** the user enables the RTAS multiplier toggle and saves
- **THEN** `VKD3D_RTAS_SIZE_MULT=8` is written to `[Env]` in `bgmod.conf`.

#### Scenario: Loading existing experimental configuration
- **WHEN** `bgmod.conf` contains any of the experimental variables
- **THEN** the corresponding toggle switches in the Experimental card are restored to ON without generating duplicate entries in the Custom Variables card.

### Requirement: Tweaks Sub-Tab Navigation for EnvVars and Arguments
Selecting Tweaks from the sidebar navigation rail SHALL display a secondary tab navigation bar with two sub-tabs: "EnvVars" and "Arguments". The EnvVars sub-tab SHALL display the environment variable category cards, while the Arguments sub-tab SHALL display the launch arguments cards.

#### Scenario: Navigating to Tweaks from sidebar
- **WHEN** user clicks on the "Tweaks" item in the sidebar navigation rail
- **THEN** the secondary tab control becomes visible with two sub-tabs labeled "EnvVars" and "Arguments".

#### Scenario: Switching between EnvVars and Arguments sub-tabs
- **WHEN** user clicks on the "Arguments" sub-tab
- **THEN** the view switches to display the launch arguments cards, and switching back to "EnvVars" displays the environment variables cards.
