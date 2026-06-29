# Capability: nonsteam-card-title-visibility

Controls the conditional rendering of game title text overlays on non-Steam game cards based on cover art availability.

## ADDED Requirements

### Requirement: Hide non-Steam game card title when cover art exists
When a non-Steam game card has a valid cover image (either cached locally or downloaded from remote sources), GOverlay SHALL hide the text label displaying the game name at the bottom of the card panel.

#### Scenario: Valid cover image loaded initially
- **WHEN** a non-Steam game card is rendered and a valid cover image exists in cache
- **THEN** GOverlay renders the card image without displaying the text title label at the bottom.

#### Scenario: Valid cover image loaded asynchronously
- **WHEN** a non-Steam game cover is successfully fetched by the background downloader thread
- **THEN** GOverlay updates the card image and hides the text title label.

### Requirement: Show non-Steam game card title when using fallback icon
When a non-Steam game card cannot resolve a valid cover image and falls back to displaying the generic GOverlay icon, GOverlay SHALL display the text label containing the game name at the bottom of the card panel.

#### Scenario: Fallback icon used for game card
- **WHEN** cover download attempts fail and the generic GOverlay icon fallback cover is generated
- **THEN** GOverlay renders the card image and displays the game name text label centered at the bottom of the card.
