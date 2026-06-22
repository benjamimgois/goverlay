## Why

When scanning Steam libraries, some games are unable to download portrait or header cover images from the standard Steam CDN, resulting in blank/missing cover slots in the user interface. GOverlay should fall back to a web image search to ensure all games have appropriate cover artwork.

## What Changes

- Pass the game name alongside the AppID in the Steam cover queue.
- Implement a fallback to `SearchWebCover` in the Steam cover download thread if Steam CDN downloads fail.

## Capabilities

### New Capabilities
- `fallback-web-search-covers`: Automatically run a Bing web image search as a fallback when portrait and header covers are missing or fail to download for Steam games.

### Modified Capabilities
<!-- None -->

## Impact

- Affected files: `games_tab.pas`.
- Improved library visual coverage by ensuring fallback images are found for obscure, non-standard, or unlisted Steam games.
