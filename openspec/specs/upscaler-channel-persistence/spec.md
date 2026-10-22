# upscaler-channel-persistence Specification

## Purpose

Defines channel selection persistence (Stable vs Bleeding-edge) for OptiScaler and DLSS Enabler across global and per-game profiles, ensuring reliable in-card status synchronization and deployment of corresponding channel assets.

## Requirements

### Requirement: Per-Profile Upscaler Channel Persistence
The system SHALL persist the selected upscaler channel (`OPT_CHANNEL`) in `bgmod.conf` for the active game profile (or global configuration) upon user selection, supporting Stable (`0`), Bleeding-edge (`1`), FSR4VK (`2`), and Custom Build (`3`), and restore that channel whenever the game profile is selected or the application is restarted.

#### Scenario: User selects Bleeding-edge channel for a game
- **WHEN** user selects "Bleeding-edge" from the channel combobox while configuring a specific game profile
- **THEN** system automatically persists `OPT_CHANNEL=1` in that game's `bgmod.conf`.

#### Scenario: User selects FSR4VK channel for a game
- **WHEN** user selects "FSR4VK" from the channel combobox while configuring a specific game profile
- **THEN** system automatically persists `OPT_CHANNEL=2` in that game's `bgmod.conf`.

#### Scenario: User selects Custom Build channel for a game
- **WHEN** user selects "Custom Build" from the channel combobox while configuring a specific game profile
- **THEN** system automatically persists `OPT_CHANNEL=3` in that game's `bgmod.conf`.

#### Scenario: Switching to game profile restores configured channel
- **WHEN** user selects a game card whose `bgmod.conf` specifies `OPT_CHANNEL=1`, `OPT_CHANNEL=2`, or `OPT_CHANNEL=3`
- **THEN** the channel combobox in the Software Status card displays the corresponding channel selection ("Bleeding-edge", "FSR4VK", or "Custom Build") instead of defaulting to "Stable Channel".

#### Scenario: Application restart preserves channel selection
- **WHEN** user restarts GOverlay and navigates to a game profile configured with `OPT_CHANNEL=2`
- **THEN** system restores the "FSR4VK" selection in the channel combobox.

### Requirement: Software Status In-Card Synchronization with Selected Channel
The system SHALL refresh the Software Status card version labels (DLSS Enabler and OptiScaler) immediately when the channel combobox selection changes or when loading a game profile, displaying the installed version corresponding to that channel.

#### Scenario: Switching channel refreshes in-card version labels
- **WHEN** user changes the channel combobox between "Stable Channel", "Bleeding-edge", "FSR4VK", and "Custom Build"
- **THEN** the Software Status card reloads local version manifest files and immediately updates the displayed version labels for the selected channel, suppressing remote update checks when Custom Build is selected.

### Requirement: Correct Channel Asset Deployment for DLSS Enabler
The system SHALL copy DLSS Enabler assets from the cache folder corresponding to the active profile's configured channel (Stable vs Bleeding-edge/Trunk) when deploying game assets.

#### Scenario: Deploying Bleeding-edge DLSS Enabler
- **WHEN** game assets are synchronized for a game configured with DLSS Enabler on the "Bleeding-edge" channel
- **THEN** system copies files from `dlssenabler-edge/` rather than defaulting to `dlssenabler-stable/`.

### Requirement: Correct Channel Asset Deployment for OptiScaler
The system SHALL deploy OptiScaler assets from the cache folder corresponding to the active profile's configured channel (`optiscaler-stable/`, `optiscaler-edge/`, `optiscaler-fsr4vk/`, or `optiscaler-custom/`) when synchronizing game assets.

#### Scenario: Deploying FSR4VK OptiScaler assets
- **WHEN** game assets are synchronized for a game configured with OptiScaler on the "FSR4VK" channel (`OPT_CHANNEL=2`)
- **THEN** system copies files from `optiscaler-fsr4vk/` (including `OptiScaler.dll` and `OptiScaler/amd_fidelityfx_upscaler_vk.dll`) into the game configuration directory.

#### Scenario: Deploying Custom Build OptiScaler assets
- **WHEN** game assets are synchronized for a game configured with OptiScaler on the "Custom Build" channel (`OPT_CHANNEL=3`)
- **THEN** system copies files from `optiscaler-custom/` into the game configuration directory.
