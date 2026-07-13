## Context

Searching for the first word in a game name is a fallback helper for very long concatenated names. However, when the game name starts with a standard article like "The", this fallback produces highly generic queries that match popular unrelated games (like "THE FINALS").

## Goals / Non-Goals

**Goals:**
- Skip "The", "A", and "An" (case-insensitive) as standalone search terms in `SearchSteamStoreGame`.

**Non-Goals:**
- Do not modify other search variants (e.g. searching the full name is still performed).

## Decisions

### Decision 1: Filter in TryName assignment
In `SearchSteamStoreGame` under `games_tab.pas`, add `SameText` checks to prevent pushing `TryName` to `Names` if it is equal to `the`, `a`, or `an`.
- **Rationale**: Highly localized, safe, and prevents generic queries from matching incorrect titles.
