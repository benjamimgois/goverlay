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
Furthermore, the Flatpak container configuration SHALL provide read-write filesystem access to native Steam data directories (`~/.local/share/Steam` and `~/.steam`) in addition to Flatpak Steam data directories (`~/.var/app/com.valvesoftware.Steam`).

#### Scenario: Creating shortcut under Flatpak
- **WHEN** GOverlay runs inside a Flatpak environment and writes a Steam shortcut
- **THEN** the `Exe` field in the shortcut is set to `"flatpak"`, and the `LaunchOptions` field is set to `"run io.github.benjamimgois.goverlay"`

#### Scenario: Creating shortcut under Flatpak for native Steam
- **WHEN** GOverlay runs inside a Flatpak environment and native Steam is installed on the host
- **THEN** GOverlay has write permissions to update `shortcuts.vdf` in `~/.local/share/Steam/userdata/*/config/` without encountering read-only permission errors.

### Requirement: Steam Userdata Path Discovery and Deduplication
The helper script SHALL discover all local Steam userdata directories and resolve symbolic links so that each unique physical `shortcuts.vdf` is processed exactly once.

#### Scenario: Resolving symlinked Steam folders
- **WHEN** Steam installations contain symlinked directories (such as `~/.steam/steam` or `~/.steam/root` pointing to `~/.local/share/Steam`)
- **THEN** the script resolves canonical paths via realpath and operates on each unique file without duplicate warnings or multiple write passes.


