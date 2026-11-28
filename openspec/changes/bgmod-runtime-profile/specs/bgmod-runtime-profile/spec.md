## ADDED Requirements

### Requirement: Runtime profile selection by game directory
When bgmod is started from the global location and automatic profile selection is enabled, bgmod SHALL resolve the game directory and load the game profile whose recorded game path contains that directory; if no such profile exists, bgmod SHALL load the global profile. The rule SHALL be the same for every launcher.

#### Scenario: Game with a profile launched with the global command
- **WHEN** `gameconfig/global/bgmod` launches a game whose resolved directory lies below the `GAME_PATH` recorded in `gameconfig/<Game>/goverlay-profile.conf`
- **AND** the identity file contains `ENABLED=1` and `gameconfig/<Game>/bgmod.conf` exists
- **THEN** bgmod reads `gameconfig/<Game>/bgmod.conf` and the game's tool configs and logs to `logs/<Game>/bgmod.log`

#### Scenario: Game without a profile
- **WHEN** the global bgmod launches a game that matches no profile
- **THEN** bgmod uses the global profile and logs that no game profile was found

#### Scenario: Folder without bgmod.conf
- **WHEN** a game folder has an identity file but no `bgmod.conf`
- **THEN** it is not treated as a profile

#### Scenario: Game-specific settings switched off
- **WHEN** a profile's identity file contains `ENABLED=0`
- **THEN** bgmod ignores the profile, including its cached `GAME_DIR`, and uses the global profile

#### Scenario: Existing profile without identity file
- **WHEN** a profile's `bgmod.conf` holds a cached `GAME_DIR` equal to the resolved game directory
- **THEN** bgmod selects that profile

#### Scenario: AppImage game
- **WHEN** the recorded `GAME_PATH` is a file
- **THEN** the profile matches only when the resolved executable path equals that file

### Requirement: Explicit per-game path wins
bgmod started from a per-game copy (`gameconfig/<Game>/bgmod`) SHALL use that profile without runtime resolution.

#### Scenario: Legacy per-game launch option
- **WHEN** a game is launched with `gameconfig/<Game>/bgmod`
- **THEN** bgmod uses `gameconfig/<Game>/` as before

### Requirement: Opt-out
Automatic profile selection SHALL be controlled by `RUNTIME_PROFILE` in the global `bgmod.conf` (default enabled) and a settings menu toggle in GOverlay.

#### Scenario: Disabled
- **WHEN** `RUNTIME_PROFILE=0`
- **THEN** the global bgmod always uses the global profile

### Requirement: Logging of the decision
bgmod SHALL log the selected profile and the reason (matched path, no match, unresolved game directory, disabled).

#### Scenario: Match logged
- **WHEN** a profile is selected at runtime
- **THEN** the log contains a `Profile:` line naming the game directory, the profile folder and the matched path

### Requirement: Generic launch command
When automatic profile selection is enabled, GOverlay SHALL show the global bgmod launch command for every game.

#### Scenario: Steam game selected
- **WHEN** the user selects a Steam game card with the setting on
- **THEN** the launch command is `"<data>/goverlay/gameconfig/global/bgmod" %command%`

### Requirement: Use game-specific settings toggle
GOverlay SHALL offer a checkable "Use game-specific settings" item in the game card context menu while automatic profile selection is enabled. Turning it on SHALL record the game's install path with `ENABLED=1` and create the profile from the global configuration when the game has no `bgmod.conf`; turning it off SHALL write `ENABLED=0` and keep the game's settings. Selecting a game card SHALL NOT enable game-specific settings, and cloning the global configuration to a game SHALL enable them.

#### Scenario: Toggle on for a new game
- **WHEN** the user enables "Use game-specific settings" for a game without settings
- **THEN** the global configuration is cloned to the game and `goverlay-profile.conf` contains the install path and `ENABLED=1`

#### Scenario: Toggle off
- **WHEN** the user disables it
- **THEN** `ENABLED=0` is written and the game's settings stay in place
