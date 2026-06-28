## ADDED Requirements

### Requirement: Local Steam librarycache cover detection
The system SHALL search all standard Linux Steam librarycache directories (`~/.steam/steam`, `~/.steam/root`, `~/.steam/debian-installation`, and Flatpak `data/Steam`) for local cover art before initiating network downloads.

#### Scenario: Detecting cover art from standard Steam Linux path
- **WHEN** Steam game card is rendered and cover image exists in `~/.steam/steam/appcache/librarycache/<AppID>/`
- **THEN** the system loads the local image immediately without triggering network requests

### Requirement: Multi-CDN cover download fallback
The background cover download thread SHALL attempt fetching cover assets from modern Steam CDN endpoints and asset variants before falling back to generic placeholder generation.

#### Scenario: Downloading vertical capsule from modern Steam CDN
- **WHEN** local cover is missing and background cover thread executes
- **THEN** the system queries `shared.akamai.steamstatic.com`, `cdn.cloudflare.steamstatic.com`, and `cdn.akamai.steamstatic.com` for `library_600x900.jpg` or `header.jpg` assets
