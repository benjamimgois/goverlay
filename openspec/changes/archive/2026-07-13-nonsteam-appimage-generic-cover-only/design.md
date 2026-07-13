## Context

AppImage filenames often contain versions and formats that trigger incorrect web search matches (like matching "Dusklight" to "THE FINALS"). Restricting AppImages to local generic covers provides a simple, clean, and predictable interface.

## Goals / Non-Goals

**Goals:**
- Skip online queries for AppImage games entirely.
- Generate generic cover art immediately for AppImages.

**Non-Goals:**
- Do not affect normal non-Steam directory-based games (which should still download online covers).

## Decisions

### Decision 1: GenerateFallbackCover on load
Inside the `else` block (when no cache image exists) in `TGamesTabHelper.LoadNonSteamFolders`, check `IsAppImage`. If true, call `GenerateFallbackCover` and do not add to `PendingItems`.
- **Rationale**: Generates local cover instantaneously (takes <1ms) and skips the queue.
