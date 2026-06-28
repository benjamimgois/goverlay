## Context

When rendering Steam games in GOverlay's Games grid (`games_tab.pas`), local covers are searched in `~/.local/share/Steam/appcache/librarycache` or Flatpak sandbox paths. On many Linux distributions (e.g. Arch, Debian, Ubuntu, Fedora, Steam Deck), Steam's data root is located at `~/.steam/steam/`, `~/.steam/root/`, `~/.steam/debian-installation/`, or `~/.var/app/com.valvesoftware.Steam/data/Steam/`.

Furthermore, when local lookup fails, `TCoverDownloadThread.Execute` attempts to download covers from `cdn.akamai.steamstatic.com`. Valve modern CDN assets use multiple domains (`shared.akamai.steamstatic.com/store_item_assets/steam/apps/<AppID>/library_600x900.jpg`, `cdn.cloudflare.steamstatic.com`) and asset variants.

## Goals / Non-Goals

**Goals:**
- Comprehensive local cover resolution from all standard Linux Steam librarycache directories.
- Robust multi-endpoint Steam CDN download logic supporting modern domains and asset variants.
- Fallback querying of Steam Store API JSON (`https://store.steampowered.com/api/appdetails?appids=<AppID>`) when direct CDN URLs fail.

**Non-Goals:**
- Changing non-Steam game folder detection or cover handling.

## Decisions

### Decision 1: Comprehensive Local Steam Librarycache Paths
- **Choice**: Add `~/.steam/steam/appcache/librarycache/`, `~/.steam/root/appcache/librarycache/`, `~/.steam/debian-installation/appcache/librarycache/`, and `~/.var/app/com.valvesoftware.Steam/data/Steam/appcache/librarycache/` to local cover file checks.
- **Rationale**: Instantly resolves covers already downloaded by Steam on disk without network overhead.

### Decision 2: Multi-CDN & Multi-Variant Download Cascade
- **Choice**: In `TCoverDownloadThread.Execute`, iterate over CDN domains (`shared.akamai.steamstatic.com/store_item_assets`, `cdn.cloudflare.steamstatic.com`, `cdn.akamai.steamstatic.com`) and asset names (`library_600x900.jpg`, `library_600x900_2x.jpg`, `header.jpg`).
- **Rationale**: Maximizes direct CDN download success rate across old and new Steam games.

## Risks / Trade-offs

- **[Risk] Multiple network requests on missing covers** → Mitigated by setting curl timeout (`--max-time 5`) and caching successful downloads immediately in `~/.cache/goverlay/covers/`.
