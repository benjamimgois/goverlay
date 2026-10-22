# Steam Shortcut Artwork Specification

## Purpose

Provides automatic deployment and lifecycle management of high-resolution Steam Grid artwork (poster, banner, hero background, logo, and icon) for GOverlay non-Steam shortcuts across Steam Deck and desktop Steam installations.

## Requirements

### Requirement: Complete Steam Grid Asset Deployment
The system SHALL deploy vertical cover art (`<id>p.png`), horizontal wide banner (`<id>.png`), hero background (`<id>_hero.png`), transparent title logo (`<id>_logo.png`), and square icon (`<id>_icon.png`) into each detected Steam user's `config/grid/` directory when adding a GOverlay Steam shortcut.

#### Scenario: Shortcut added on Steam Deck or Desktop
- **WHEN** the user executes the Steam shortcut creation for GOverlay
- **THEN** the system copies or generates all 5 artwork assets in the `config/grid/` directory for each discovered Steam userdata profile.

### Requirement: Dual ID Compatibility
The system SHALL deploy the artwork assets with filenames matching both the 64-bit Grid ID (`((appid << 32) | 0x02000000)`) and the 32-bit AppID format to guarantee visual compatibility across SteamOS Gaming Mode, Big Picture, and legacy/desktop Steam clients.

#### Scenario: Artwork indexing by Steam client
- **WHEN** Steam or SteamOS Gaming Mode indexes the shortcut artwork
- **THEN** the library grid, recent games banner, hero background, logo overlay, and list icon resolve to the custom GOverlay artwork without fallback placeholders.

### Requirement: Artwork Cleanup on Shortcut Removal
The system SHALL delete all GOverlay Steam Grid artwork files associated with the shortcut IDs from the user's `config/grid/` directory when removing the GOverlay Steam shortcut.

#### Scenario: Shortcut removed
- **WHEN** the Steam shortcut removal action is executed
- **THEN** all associated GOverlay artwork files are removed from the `config/grid/` folder of all target user profiles.
