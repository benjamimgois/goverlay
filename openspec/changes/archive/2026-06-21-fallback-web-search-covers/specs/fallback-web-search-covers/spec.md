## ADDED Requirements

### Requirement: Fallback to web search when Steam CDN download fails
When portrait and header cover images fail to download from Steam's CDN for a game in a Steam library, GOverlay SHALL perform a web search fallback using the game's name to find and download a cover image.

#### Scenario: Steam CDN download fails but web search succeeds
- **WHEN** portrait cover and header cover download attempts fail for a Steam game, and a web search for the game cover succeeds
- **THEN** GOverlay downloads and saves the web cover image to the cache path, and updates the game card image in the UI.

#### Scenario: Steam CDN download fails and web search also fails
- **WHEN** portrait cover and header cover download attempts fail for a Steam game, and a web search for the game cover also fails
- **THEN** GOverlay SHALL generate/load a fallback cover image containing the GOverlay icon centered on a dark background, save it to the cache path, and update the game card image in the UI.

