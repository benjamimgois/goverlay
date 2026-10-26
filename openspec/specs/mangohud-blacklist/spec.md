# mangohud-blacklist Specification

## Purpose
Provides process name blacklisting for MangoHud, preventing the overlay from hooking into selected desktop applications and tools.

## Requirements

### Requirement: Real-time blacklist synchronization
The system SHALL immediately update the `blacklist=` directive in the active host, global gameconfig profile, and Steam Flatpak `MangoHud.conf` configurations whenever a process is added to or removed from the blacklist modal.

#### Scenario: Process added to blacklist
- **WHEN** user adds a process name in the Blacklisted Apps dialog
- **THEN** the process name is appended to `blacklist.conf` and immediately written to the `blacklist=` directive in host `MangoHud.conf` and `gameconfig/global/MangoHud.conf`

#### Scenario: Process removed from blacklist
- **WHEN** user removes a process name from the Blacklisted Apps dialog
- **THEN** the process name is removed from `blacklist.conf` and the updated list is immediately written to the `blacklist=` directive in host `MangoHud.conf` and `gameconfig/global/MangoHud.conf`

### Requirement: Host and sandbox path consistency
The system SHALL resolve `blacklist.conf` using standardized XDG paths that respect `HOST_XDG_CONFIG_HOME` when executing under containerized or Flatpak environments.

#### Scenario: Resolving blacklist path in sandbox or host
- **WHEN** the system reads or writes `blacklist.conf`
- **THEN** the path is resolved via the centralized configuration manager to ensure compatibility across host, AppImage, and Flatpak runs

### Requirement: Steam Flatpak configuration mirroring
The system SHALL propagate the updated blacklist line to the Steam Flatpak `MangoHud.conf` configuration file when that file exists on the system.

#### Scenario: Blacklist updated with Steam Flatpak installed
- **WHEN** the blacklist is updated
- **THEN** both the host `MangoHud.conf`, the global profile `gameconfig/global/MangoHud.conf`, and `~/.var/app/com.valvesoftware.Steam/config/MangoHud/MangoHud.conf` are updated if the Steam Flatpak directory exists

### Requirement: Modern blacklist dialog user experience
The system SHALL present a modern, keyboard-accessible dialog matching GOverlay theme styling for managing blacklisted processes.

#### Scenario: Keyboard navigation in blacklist dialog
- **WHEN** user presses Enter in the process name text input
- **THEN** the process is added without requiring a manual mouse click on the Add button

#### Scenario: Keyboard deletion of blacklisted process
- **WHEN** user selects an item in the blacklist and presses Delete or Backspace
- **THEN** the selected item is removed and the configuration files are synchronized immediately
