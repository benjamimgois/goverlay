## Why

Currently, games added via "nonsteam folders" display their title as text at the bottom of the card panel. This text overlay is unnecessary when a proper cover image is loaded, as the cover art clearly identifies the game and the text clutter reduces visual quality. However, when no cover image can be identified and the application falls back to displaying the generic GOverlay icon, the text title is still necessary to identify the game.

## What Changes

- Hide the text title overlay at the bottom of non-Steam game cards when a valid game cover image is loaded.
- Keep and display the text title overlay ONLY when the game relies on the fallback GOverlay icon.
- Dynamically toggle the visibility of the card title label when cover images finish loading asynchronously.

## Capabilities

### New Capabilities
- `nonsteam-card-title-visibility`: Controls conditional rendering of game title labels on non-Steam game cards based on whether cover art is loaded or using fallback icons.

### Modified Capabilities

## Impact

- `games_tab.pas`: Updates card panel setup for non-Steam folders, cover image load logic, and asynchronous cover updates (`TNonSteamCoverThread`).
