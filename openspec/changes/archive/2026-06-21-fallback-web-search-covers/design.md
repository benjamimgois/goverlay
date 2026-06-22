## Context

Currently, the Steam cover download thread `TCoverDownloadThread` only receives `AppIDs` and attempts to fetch cover files from Steam's CDN. If these fetch attempts fail, it has no fallback, resulting in blank game cards. GOverlay already implements a web search fallback `SearchWebCover` for non-Steam games, which we can reuse for Steam games.

## Goals / Non-Goals

**Goals:**
- Enable `TCoverDownloadThread` to perform a web search fallback when standard Steam CDN downloads fail.
- Re-use GOverlay's existing `SearchWebCover` method.
- Generate a fallback cover featuring the GOverlay icon centered on a dark background if both CDN and web search fail.

**Non-Goals:**
- Changing the constructor of `TCoverDownloadThread` or adding new thread parameters.
- Fetching covers from third-party APIs (like SteamGridDB) directly within the wrapper.

## Decisions

### 1. Key-Value Formatting in `PendingIDs`
- **Decision:** Store items in the `PendingIDs` string list as `AppID=GameName`.
- **Rationale:** Storing the game name with the AppID as a name-value pair avoids changing the class/constructor interface and allows `TCoverDownloadThread` to easily parse the game name via `FAppIDs.ValueFromIndex[i]`.

### 2. Invoke `SearchWebCover` on Failure
- **Decision:** If both portrait and header cover download attempts fail, check if `GameName` is present and invoke `FForm.SearchWebCover(GameName, OutPath)` to search Bing and cache the cover.
- **Rationale:** Reuses existing web search capability without duplication.

### 3. GOverlay Icon Fallback Generation
- **Decision:** If both CDN and web search fail, programmatically generate a cover image at `OutPath` by creating a `TBitmap` of size `CARD_W` x `CARD_H` (150x215) filled with a dark background (color `$252525`). Then, load the GOverlay PNG icon (`GetAppBaseDir + 'data/icons/128x128/goverlay.png'`), draw/stretch it proportionally at the center of the dark background, and save it as a JPEG to `OutPath`.
- **Rationale:** Ensures that games that fail to resolve any cover art still have a clean, uniform card representation in the games grid instead of an empty space or a completely black block, while keeping the GOverlay branding subtle.

## Risks / Trade-offs

- **Risk:** Parsing overhead of string splitting in the thread.
  - *Mitigation:* Extremely minor for library counts (typically less than a few hundred items) and executed on a background thread.
- **Risk:** LCL Graphic rendering in background threads.
  - *Mitigation:* We will perform standard memory bitmap drawing (which is thread-safe on Linux/LCL) and save to the cache file. If any unexpected crash occurs, we can wrap the fallback creation in `try..except` blocks.

