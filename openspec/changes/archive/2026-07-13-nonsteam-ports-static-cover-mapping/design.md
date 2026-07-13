## Context

Cover searching relies on the game name matches. Unofficial ports and decompilation projects have names that don't match the original titles, preventing metadata/artwork lookup.

## Goals / Non-Goals

**Goals:**
- Translate project names to their official titles using a static array of popular ports.
- Avoid introducing any network requests or XML/HTML parsers.

**Non-Goals:**
- Do not perform live web parsing (to avoid delay, rate limits, or structure breaking).
- Do not modify cover cache filenames (covers are saved under the original port name).

## Decisions

### Decision 1: STATIC_PORT_MAPPINGS Database
Implement `STATIC_PORT_MAPPINGS` in `games_tab.pas` as a constant array of structures containing `PortName` and `GameName`.
- **Rationale**: Highly efficient, offline, and predictable.

### Decision 2: ResolveUnofficialPortName Helper
Implement a lookup helper that lowercases, trims, and searches the array.
- **Rationale**: Keeps search translation centralized.

### Decision 3: Map name in background thread loop
In `TNonSteamCoverThread.Execute`, call `ResolveUnofficialPortName` to get the target string for searches.
- **Rationale**: Minimal modification to core search logic.
