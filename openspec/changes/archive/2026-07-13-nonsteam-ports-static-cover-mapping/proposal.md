## Why

Unofficial ports, decompilations, and source ports of popular video games (e.g. `courage reborn` or `dusklight` for Zelda Twilight Princess, `ship of harkinian` for Zelda Ocarina of Time, `smw` for Super Mario World, etc.) do not have covers on Steam Store or Bing when searched by their project name. By introducing a static translation dictionary, we can map project names to their original official video game titles before conducting the cover search. This resolves the lack of custom covers for decompilation games without introducing any runtime network delay or external parser complexity.

## What Changes

- Implement a static lookup database of popular unofficial ports and their corresponding official game names.
- Translate the search string to the official game name when launching background cover image searches.

## Capabilities

### New Capabilities
- `nonsteam-ports-static-cover-mapping`: Map project names to official names before performing online cover searches.

### Modified Capabilities
<!-- None -->

## Impact

- `games_tab.pas`: Define `TPortMapping` record, `STATIC_PORT_MAPPINGS` constant array, and add `ResolveUnofficialPortName` lookup helper.
- `games_tab.pas` (`TNonSteamCoverThread.Execute`): Translate name before calling `SearchSteamStoreGame` and `SearchWebCover`.
