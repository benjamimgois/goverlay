## Purpose

Defines channel selection persistence (Stable vs Bleeding-edge) for OptiScaler and DLSS Enabler across global and per-game profiles, ensuring reliable in-card status synchronization and deployment of corresponding channel assets.

## ADDED Requirements

### Requirement: Per-Profile Upscaler Channel Persistence
The system SHALL persist the selected upscaler channel (`OPT_CHANNEL`) in `bgmod.conf` for the active game profile (or global configuration) upon user selection, and restore that channel whenever the game profile is selected or the application is restarted.

#### Scenario: User selects Bleeding-edge channel for a game
- **WHEN** user selects "Bleeding-edge" from the channel combobox while configuring a specific game profile
- **THEN** system automatically persists `OPT_CHANNEL=1` in that game's `bgmod.conf`.

#### Scenario: Switching to game profile restores configured channel
- **WHEN** user selects a game card whose `bgmod.conf` specifies `OPT_CHANNEL=1`
- **THEN** the channel combobox in the Software Status card displays "Bleeding-edge" instead of defaulting to "Stable Channel".

#### Scenario: Application restart preserves channel selection
- **WHEN** user restarts GOverlay and navigates to a game profile configured with `OPT_CHANNEL=1`
- **THEN** system restores the "Bleeding-edge" selection in the channel combobox.

### Requirement: Software Status In-Card Synchronization with Selected Channel
The system SHALL refresh the Software Status card version labels (DLSS Enabler and OptiScaler) immediately when the channel combobox selection changes or when loading a game profile, displaying the installed version corresponding to that channel.

#### Scenario: Switching channel refreshes in-card version labels
- **WHEN** user changes the channel combobox between "Stable Channel" and "Bleeding-edge"
- **THEN** the Software Status card reloads local version manifest files and immediately updates the displayed version labels for the selected channel.

### Requirement: Correct Channel Asset Deployment for DLSS Enabler
The system SHALL copy DLSS Enabler assets from the cache folder corresponding to the active profile's configured channel (Stable vs Bleeding-edge/Trunk) when deploying game assets.

#### Scenario: Deploying Bleeding-edge DLSS Enabler
- **WHEN** game assets are synchronized for a game configured with DLSS Enabler on the "Bleeding-edge" channel
- **THEN** system copies files from `dlssenabler-edge/` rather than defaulting to `dlssenabler-stable/`.
