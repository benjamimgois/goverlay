# steam-shortcut-settings Specification

## Purpose
This specification defines the requirements for integrating GOverlay with Steam by adding a "Create Steam shortcut" option in the settings menu, enabling native and Flatpak container launches directly from Steam.
## Requirements
### Requirement: Create Steam Shortcut Settings Option
The GOverlay interface SHALL display a "Create Steam shortcut" option in its settings popup menu. Clicking this option SHALL execute a helper script to register GOverlay as a non-Steam game shortcut.

#### Scenario: User opens settings menu
- **WHEN** the user clicks the Settings gear icon
- **THEN** the popup menu shows the "Create Steam shortcut" item with a Steam icon

#### Scenario: User clicks Create Steam shortcut
- **WHEN** the user clicks "Create Steam shortcut" in the settings menu
- **THEN** GOverlay executes the python helper script with parameters for the GOverlay executable path and GOverlay icon path

### Requirement: Steam running detection
The helper script SHALL check if Steam is currently running. If Steam is running, the user SHALL be warned that they need to close Steam or restart it to apply the changes.

#### Scenario: Creating shortcut while Steam is active
- **WHEN** the user clicks "Create Steam shortcut" and the `steam` process is detected in the system
- **THEN** the system displays a message: "Steam is currently running. Please close Steam before making modifications to ensure shortcuts are saved properly."

### Requirement: Flatpak sandbox compatibility
The helper script SHALL detect if it is running within a Flatpak sandbox. If so, it SHALL configure the shortcut to launch via Flatpak rather than directly referencing the sandbox's internal binary path.

#### Scenario: Creating shortcut under Flatpak
- **WHEN** GOverlay runs inside a Flatpak environment and writes a Steam shortcut
- **THEN** the `Exe` field in the shortcut is set to `"flatpak"`, and the `LaunchOptions` field is set to `"run io.github.benjamimgois.goverlay"`

