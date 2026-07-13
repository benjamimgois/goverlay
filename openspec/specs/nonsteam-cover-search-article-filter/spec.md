# nonsteam-cover-search-article-filter Specification

## Purpose
TBD - created by archiving change nonsteam-cover-search-article-filter. Update Purpose after archive.
## Requirements
### Requirement: Skip Generic Articles in First-Word Search
When GOverlay extracts the first word of a long game name (longer than 20 characters) to use as a fallback search variant for cover art on the Steam Store, it SHALL skip adding this variant if the first word is a common generic article (e.g. `"The"`, `"A"`, `"An"`).

#### Scenario: Skipping Article For Zelda Search
- **WHEN** GOverlay searches cover art for the game `The Legend of Zelda: Twilight Princess`
- **THEN** the first-word search query variant `"The"` is skipped and is not queried to the Steam Store API.

