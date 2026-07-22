## ADDED Requirements

### Requirement: Blacklist included in all MangoHud configurations
The system SHALL append the active blacklist (`blacklist=app1,app2,...`) stored in `~/.config/goverlay/blacklist.conf` to every generated MangoHud configuration file, including global configuration (`MangoHud.conf`) and per-game configuration files (`~/.config/goverlay/<game>/MangoHud.conf`).

#### Scenario: Saving a per-game profile with active blacklist
- **WHEN** user saves MangoHud settings for a specific game profile
- **THEN** system writes the `blacklist=...` line containing all blacklisted apps into the game-specific `MangoHud.conf` file

#### Scenario: Saving global configuration with active blacklist
- **WHEN** user saves global MangoHud settings
- **THEN** system writes the `blacklist=...` line into `~/.config/MangoHud/MangoHud.conf`

### Requirement: Blacklist entries updated dynamically
The system SHALL overwrite or update existing `blacklist=` lines when saving settings, ensuring any additions or removals of blacklisted applications take effect immediately upon save.

#### Scenario: Updating blacklist entries in an existing configuration
- **WHEN** user modifies blacklisted apps in GOverlay and saves settings
- **THEN** system replaces the existing `blacklist=` line in the target MangoHud configuration file with the updated list of blacklisted applications
