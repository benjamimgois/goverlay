## MODIFIED Requirements

### Requirement: Settings Persistence & Per-Game Integration
1. GOverlay SHALL use `lsfg.toml` as the single source of truth for all detailed Lossless Scaling options (including `dll`, `multiplier`, `flow_scale`, `performance_mode`, `hdr_mode`, and `experimental_present_mode`), parsing `lsfg.toml` upon loading the tab and saving directly to `lsfg.toml`.
2. Global and per-game configuration files (`bgmod.conf`) SHALL only store `GOVERLAY_LOSSLESS=1` (when enabled) or `GOVERLAY_LOSSLESS=0` (when disabled) in the `[Config]` section, without storing redundant `LS_*` or `LSFG_*` configuration keys in `[Config]` or `[Env]`.
3. When Lossless Scaling is disabled (or multiplier set to 1x), GOverlay SHALL set `GOVERLAY_LOSSLESS=0` and remove `lsfg.toml` from the target configuration directory.
4. When launching a game with `GOVERLAY_LOSSLESS=1`, `bgmod` SHALL ensure `lsfg.toml` contains the target game executable profile and pass `LSFG_CONFIG="<game_dir>/lsfg.toml"` to the execution environment.
5. Global mode configurations (`gameconfig/global/`) and game-specific configurations (`gameconfig/<game>/`) SHALL remain strictly isolated; switching between Global mode and any game profile in GOverlay SHALL load that profile's saved configuration from disk without overwriting or leaking in-memory UI values across contexts.

#### Scenario: Loading Lossless Scaling configuration
- **WHEN** the user opens the Lossless Scaling tab or selects a game with an existing `lsfg.toml`
- **THEN** GOverlay reads and parses `lsfg.toml` to populate the DLL path, multiplier, flow scale, performance mode, HDR mode, and pacing mode dropdown.

#### Scenario: Saving Lossless Scaling configuration
- **WHEN** the user saves settings with Lossless Scaling enabled
- **THEN** GOverlay writes all options directly to `lsfg.toml` in the target config directory
- **AND** writes `GOVERLAY_LOSSLESS=1` to `bgmod.conf` `[Config]` while omitting redundant `LS_*` keys.

#### Scenario: Disabling Lossless Scaling
- **WHEN** the user sets the multiplier to 1x or disables Lossless Scaling
- **THEN** GOverlay writes `GOVERLAY_LOSSLESS=0` to `bgmod.conf` `[Config]` and removes `lsfg.toml`.

#### Scenario: Launching a game with Lossless Scaling enabled
- **WHEN** a game is launched with Lossless Scaling active
- **THEN** `bgmod` writes `lsfg.toml` to the game's directory and exports `LSFG_CONFIG="<game_dir>/lsfg.toml"` to the game execution environment.

#### Scenario: Context Isolation between Global and Game Profiles
- **WHEN** the user configures Lossless Scaling settings in Global mode (e.g. 4x FPS, 80% Flow Scale)
- **AND** subsequently navigates to a game profile (or vice versa)
- **THEN** GOverlay loads the game profile's independent configuration without overwriting it with Global values
- **AND** returning to Global mode restores the Global configuration intact.
