# Design

## Context

GOverlay manages both Steam and non-Steam games in `games_tab.pas`. Steam games have well-defined AppIDs and cached covers in Steam's `appcache/librarycache/`. Non-Steam games are scanned from directories in `nonsteam_folders.txt`, identified only by `GameName` and `SubPath`. Cover art is currently saved exclusively as `.jpg` in `~/.cache/goverlay/nonsteam_covers/`. Failed `curl` downloads (HTTP 404/403) write truncated error HTML pages into the cache path without deletion, and `TNonSteamCoverThread` skips retry whenever `FileExists` is true, causing permanent blank cards. Furthermore, game cards scale all images to 140x210 portrait geometry via unconstrained `StretchDraw`.

## Goals / Non-Goals

**Goals:**
- Provide a robust local-first cascade: GOverlay cache -> local game folder -> Heroic Games Launcher -> Lutris -> safe remote download fallback -> branded fallback.
- Detect, reject, and clean up truncated or invalid image files ($\le 2048$ bytes or load exceptions).
- Implement an aspect-ratio preserving crop helper (`DrawCoverAspectFill`) so square and wide cover art displays centered and distortion-free.
- Support `.png`, `.jpg`, and `.jpeg` transparently across cache lookup and custom art assignment.
- Enable user-driven cover assignment and reset via `FGameCardMenu` actions.

**Non-Goals:**
- Implementing an in-app interactive cropping GUI editor (standard centered "cover" fill suffices).
- Bundling heavy image processing libraries (uses native FreePascal/Lazarus LCL graphics).
- Rewriting the background thread architecture from scratch.

## Decisions

### 1. Robust Download with Temp Files and Validation
- **Decision**: In `DownloadSteamCover` and `SearchWebCover`, download to a unique temp file (`GetTempDir + ...tmp`) using `curl --fail -s -L`. Only move/rename to the target cache path if curl exited cleanly, the file size exceeds 2048 bytes, and `TPicture` can successfully parse it.
- **Alternatives considered**:
  - *Download directly to destination*: Led to the 146-byte corruption bug reported in issue #446.

### 2. Multi-Provider Local Artwork Resolution Helper
- **Decision**: Introduce `function ResolveNonSteamLocalCover(const AGameName, ASubPath: string; out ACoverPath: string): Boolean;` that checks:
  1. `~/.cache/goverlay/nonsteam_covers/<SanitizedName>.(png|jpg|jpeg)` (size > 2048)
  2. Local `ASubPath` for `cover.(png|jpg|jpeg)`, `poster.*`, `folder.*`
  3. Heroic Launcher: check native (`~/.config/heroic/`) and Flatpak (`~/.var/app/com.heroicgameslauncher.hgl/config/heroic/`) `icons/<app_name>.(jpg|png)` matching by `SubPath` or title from `sideload_apps/library.json`, `store_cache/legendary_install_info.json`, `store_cache/legendary_library.json`, `store_cache/gog_library.json`
  4. Lutris: check native (`~/.local/share/lutris/`) and Flatpak (`~/.var/app/net.lutris.Lutris/data/lutris/`) `coverart/<slug>.(jpg|png)` and `banners/<slug>.(jpg|png)`
- **Rationale**: Local discovery is instantaneous and offline. Network search only runs if all local sources fail.

### 3. Proportional Scaling (Center Crop / Aspect Fill)
- **Decision**: Create `procedure DrawCoverAspectFill(ACanvas: TCanvas; const ADstRect: TRect; AGraphic: TGraphic);`.
  - Computes `SrcAspect := Graphic.Width / Graphic.Height` vs `DstAspect := DstRect.Width / DstRect.Height`.
  - Centers and crops the excess width or height from `AGraphic` before drawing into `ADstRect`.
- **Alternatives considered**:
  - *Letterboxing (Aspect Fit)*: Leaves awkward black/empty bars on cards, breaking grid uniformity.
  - *Blind StretchDraw*: Distorts and stretches images (current behavior).

### 4. Custom Cover Integration via Context Menu
- **Decision**: Add `FSetCoverMenuItem` ("Set custom cover...") and `FResetCoverMenuItem` ("Reset cover art") to `FGameCardMenu`.
  - "Set custom cover...": opens `TOpenDialog`, copies chosen image into `~/.cache/goverlay/nonsteam_covers/<SanitizedName>.<ext>`, removes companion `.fallback`, and reloads card bitmap and sidebar thumbnail immediately.
  - "Reset cover art": deletes cached image and `.fallback`, re-triggers discovery or fallback generation.

## Risks / Trade-offs

- **[Risk] Existing users have corrupt 146-byte files on disk** -> **Mitigation**: On startup and inside `TNonSteamCoverThread`, if a cached file is $\le 2048$ bytes, automatically delete it and proceed with resolution/download.
- **[Risk] Heroic or Lutris configurations might be large JSON files** -> **Mitigation**: Only scan installed/sideload files (`sideload_apps/library.json`, `legendary_install_info.json`) first before broader library files; parsing uses lightweight stream search or targeted key scanning.
