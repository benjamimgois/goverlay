# Proposal

## Why

Non-Steam games (such as those installed via Lutris, Heroic Games Launcher, or custom directories) frequently display blank tiles or distorted artwork in the Games tab and the per-game tweaking view. This occurs because failed web downloads write 146-byte HTTP error responses directly into the cover cache, which GOverlay treats as permanently cached without retry or fallback generation. Additionally, GOverlay only checks for `.jpg` files, lacks integration with existing local cover repositories from Lutris and Heroic, lacks custom cover selection in the game card action menu, and distorts non-portrait artwork due to unconstrained stretching.

## What Changes

- **Resilient Cover Download & Cache Sanitation**: Add `--fail` to `curl` executions, download to temporary files (`.tmp`), validate image size (> 2KB) and validity before committing to cache, and purge existing corrupt (<= 2048 B) cache files to allow retry or fallback generation.
- **Local Art Resolution (Heroic & Lutris & Folder)**: Implement zero-network local cover lookup before remote queries:
  - Check local game directory (`SubPath`) for `cover.(png|jpg|jpeg)`, `poster.*`, `folder.*`.
  - Check Heroic Games Launcher cover cache (`icons/<app_name>.(jpg|png)`) matching by path or title in both native (`~/.config/heroic/`) and Flatpak paths.
  - Check Lutris coverart cache (`coverart/<slug>.(jpg|png)`) in both native (`~/.local/share/lutris/`) and Flatpak paths.
- **Multi-Format Image Support**: Expand cover detection and loading to support `.png`, `.jpg`, and `.jpeg` (and conversion for `.webp` where available) across cache and local providers.
- **Aspect-Ratio Preserving Scaling (Center Crop / Aspect Fill)**: Replace blind `StretchDraw` with proportional center-crop scaling to eliminate distortion on square ($1:1$) or widescreen ($16:9$) images while filling the 2:3 card geometry.
- **Custom Cover Art Management**: Add "Set custom cover..." (`TOpenDialog`) and "Reset cover art" actions to the 3-dots card popup menu (`FGameCardMenu`), updating both the card tile and per-game preview immediately.

## Capabilities

### New Capabilities
- `nonsteam-game-covers`: Covers multi-source cover art discovery (GOverlay cache, game folder, Heroic, Lutris), multi-format image loading, aspect-ratio preserving crop, and custom cover management from the game card context menu.

### Modified Capabilities
- `game-card-fallback-covers`: Updates fallback trigger conditions so that corrupt, truncated, or failed cover files automatically yield to the official GOverlay fallback cover rather than blank tiles.

## Impact

- **Affected Code**: `games_tab.pas` (`TNonSteamCoverThread`, `SearchWebCover`, `DownloadSteamCover`, `LoadSteamGames`, `CreateActionPanel`, `FGameCardMenu`, cover drawing helpers) and `overlayunit.pas`.
- **User Data**: Files in `~/.cache/goverlay/nonsteam_covers/` will be validated and cleaned if invalid; valid custom covers placed by users will persist.
- **Dependencies**: No external library additions; uses standard FreePascal/Lazarus graphical units (`Graphics`, `FPReadPNG`, `FPReadJPEG`) and existing system `curl`.
