# nonsteam-ports-static-cover-mapping Specification

## Purpose
TBD - created by archiving change nonsteam-ports-static-cover-mapping. Update Purpose after archive.
## Requirements
### Requirement: Translate Port Names to Official Game Names
GOverlay SHALL translate unofficial port project names (e.g., `dusklight`, `smw`, `ship of harkinian`) to their original official game names before invoking Steam Store API search or Web cover image search.

#### Scenario: Translating Dusklight
- **WHEN** the non-Steam cover search thread processes the game named `Dusklight`
- **THEN** it translates the search query to `The Legend of Zelda: Twilight Princess` before querying Steam Store and Bing.

#### Scenario: Translating Ship of Harkinian
- **WHEN** the non-Steam cover search thread processes the game named `Ship of Harkinian`
- **THEN** it translates the search query to `The Legend of Zelda: Ocarina of Time` before querying Steam Store and Bing.

