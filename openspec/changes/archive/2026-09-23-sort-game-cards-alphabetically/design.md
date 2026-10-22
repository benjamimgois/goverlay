# Design: Unified Alphabetical Sorting for Game Cards

## Context

See `proposal.md` for motivation. Currently, in [`games_tab.pas`](file:///mnt/NVME/Software/goverlay/games_tab.pas), `LoadSteamGames` immediately instantiates `TPanel` and `TImage` controls as each Steam `appmanifest_*.acf` is read from disk. Once all Steam libraries are scanned, `LoadNonSteamFolders` is called, which scans custom folders and `.appimage` files, immediately appending them to `FCardPanels`. This results in cards appearing in filesystem directory entry order, with non-Steam games strictly at the end.

## Goals / Non-Goals

**Goals:**
- Decouple game library discovery from UI card construction in `games_tab.pas`.
- Merge Steam and non-Steam discovered games into a unified in-memory collection and sort alphabetically (A-Z).
- Sort case-insensitively, placing digits and symbols first, and keeping leading articles (e.g., "The") under their first letter ("T").
- Preserve all existing badge calculations, context menus, click handlers, and asynchronous cover download workflows (`TCoverDownloadThread` and `TNonSteamCoverThread`).

**Non-Goals:**
- Interactive search bars or filter inputs (deferred for future enhancements).
- Dynamic sort mode selectors (A-Z vs Z-A vs source platform).
- Virtualized scrolling or lazy card instantiation.

## Decisions

### 1. Two-phase discovery and rendering
- **Decision**: Introduce a lightweight record type (e.g. `TGameDiscoveryItem`) to capture game metadata during initial scan, then instantiate UI controls only after the list has been sorted.
  ```pascal
  type
    TGameKind = (gkSteam, gkNonSteam);
    TGameDiscoveryItem = record
      Kind: TGameKind;
      Name: string;
      AppID: string;
      InstallDir: string;
      LibPath: string;
      SubPath: string;
      IsAppImage: Boolean;
    end;
  ```
- **Rationale**: Memory allocation for a dynamic array of records is negligible (a few kilobytes for hundreds of games). Separating discovery from control construction avoids LCL layout recalculations, widget flickering, or moving controls around after creation.
- **Alternatives considered**:
  - *Post-creation sorting of `FCardPanels`*: Would require re-indexing `FOrigCovers`, updating `TNonSteamCoverItem.CardIndex`, and re-invoking `ReflowGamesGrid`. This is brittle and error-prone.

### 2. Unified comparison function
- **Decision**: Sort the aggregated collection using a deterministic case-insensitive comparison (`AnsiCompareText`). If two items share the identical display name, use their source kind (`Kind`) and path/AppID as tie-breakers.
- **Rationale**: `AnsiCompareText` places symbols and digits before letters, handles UTF-8 characters safely, and treats uppercase/lowercase consistently. Keeping "The" intact directly matches Steam's own library sorting behavior.
- **Alternatives considered**:
  - *Article-stripping ("The Witcher" -> "Witcher, The")*: Rejected to align with Steam and user preference.
  - *Platform separation (Steam A-Z followed by Non-Steam A-Z)*: Rejected in favor of a unified A-Z library where platform badges already indicate the source.

### 3. Asynchronous cover thread compatibility
- **Decision**: Populate `PendingIDs`, `PendingImages`, and `PendingItems` in the exact sorted order as cards are created.
- **Rationale**:
  - `TCoverDownloadThread` associates covers by direct `TImage` references and looks up `CardPanel := TPanel(FCurrentImage.Parent)` dynamically.
  - `TNonSteamCoverThread` associates covers using `CardIndex := FCardPanels.Count - 1`. Because cards are added to `FCardPanels` in sorted order, each card's index in `FCardPanels` is known and immutable during creation.

### 4. Zero-game handling
- **Decision**: Display `NoGamesLabel` only if total discovered games (Steam + Non-Steam) equals 0.
- **Rationale**: In the legacy implementation, if Steam libraries were empty (`Libraries.Count = 0`), the procedure exited early and never checked non-Steam folders. The unified discovery ensures users who only configure non-Steam games still see their library.

## Risks / Trade-offs

- **[Risk] High game counts causing sort overhead**:
  - *Mitigation*: In-memory QuickSort on an array of 1,000 records takes < 1 ms in FreePascal, completely dominated by filesystem I/O and cover image loading.
- **[Risk] Broken indices in cover threads**:
  - *Mitigation*: Verify that `PendingItems[i].CardIndex` and `FOrigCovers` stay in exact 1:1 synchronization with `FCardPanels`.
