# Proposal: Sort Game Cards Alphabetically

## Why

Currently, game cards in the Games tab are loaded in arbitrary filesystem inode order per library, with non-Steam games appended at the very end after all Steam games. For users with large game libraries (tens or hundreds of titles), locating specific games is frustrating and inefficient.

## What Changes

- Decouple game discovery (reading Steam manifests and scanning non-Steam folders) from immediate UI control instantiation in `games_tab.pas`.
- Aggregate all discovered games into a unified in-memory list prior to card construction.
- Sort games in unified alphabetical order (A-Z):
  - Case-insensitive comparison (`AnsiCompareText`).
  - Symbols and numbers appear before letters (standard ASCII order).
  - Strict article ordering matching Steam conventions (titles starting with "The" remain under "T").
  - Interleave Steam and non-Steam games alphabetically, preserving distinct platform badges on cards.
- Render game cards in the sorted order, preserving existing asynchronous cover loading, ribbons, and context menus.

## Capabilities

### New Capabilities
- `game-library-sorting`: Covers unified alphabetical ordering (A-Z) of game cards in the Games tab.

### Modified Capabilities
<!-- None -->

## Impact

- **Affected code**: `games_tab.pas` (`TGamesTabHelper.LoadSteamGames`, `LoadNonSteamFolders`, and helper data structures/routines).
- **Tests**: Add test cases in `tests/gui/gui_test_cases.pas` and/or `tests/logic/logic_test_cases.pas` verifying that game cards appear in alphabetical order.
- **Breaking changes**: None. Existing card menus, badges, hover animations, launch commands, and config persistence remain unchanged.
