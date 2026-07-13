## Why

When searching for cover art on the Steam Store API for long game names starting with a common article (e.g. `The Legend of Zelda: Twilight Princess`), GOverlay generates a search variant using the first word (e.g. `The`). Searching the Steam Store API with a generic article like `"The"` returns completely unrelated matches (such as `"THE FINALS"`), resulting in GOverlay downloading and applying the wrong cover image for the game. Filtering out common articles from the first-word search variant solves this false positive lookup.

## What Changes

- Filter out generic articles (`"The"`, `"A"`, `"An"`) from the first-word search query variant inside the Steam Store cover search method.

## Capabilities

### New Capabilities
- `nonsteam-cover-search-article-filter`: Skip generic articles for the first-word cover search query variant.

### Modified Capabilities
<!-- None -->

## Impact

- `games_tab.pas` (`SearchSteamStoreGame`): Add checks to prevent adding "The", "A", or "An" as search terms.
