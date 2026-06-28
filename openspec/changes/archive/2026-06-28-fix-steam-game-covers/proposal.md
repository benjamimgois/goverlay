## Why

Several installed Steam games fail to display their cover art in GOverlay's Games tab, resulting in blank placeholder cards. This happens because local Steam librarycache lookups miss standard Linux installation paths (`~/.steam/steam`, `~/.steam/root`, etc.) and CDN download fallbacks do not query modern Steam CDN endpoints.

## What Changes

- Expand local Steam librarycache search paths in `games_tab.pas` to include `~/.steam/steam/`, `~/.steam/root/`, `~/.steam/debian-installation/`, and Flatpak `~/.var/app/com.valvesoftware.Steam/data/Steam/`.
- Update `TCoverDownloadThread.Execute` to attempt modern Steam CDN domains (`shared.akamai.steamstatic.com`, `cdn.cloudflare.steamstatic.com`) and asset variants (`_2x`, `_english`).
- Add fallback querying of Steam Store API (`https://store.steampowered.com/api/appdetails?appids=<AppID>`) when direct CDN assets are unavailable.

## Capabilities

### New Capabilities

- `steam-game-cover-resolution`: Discovers, caches, and renders cover artwork for Steam library games across Linux installation types.

### Modified Capabilities

(none)

## Impact

- `games_tab.pas`: Local cover path checking and background cover download thread updated.
