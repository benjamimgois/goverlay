## Why

When GOverlay is launched with empty configurations (e.g. after clearing settings), it attempts to resolve missing covers for all Steam and non-Steam games using background threads. If these downloads fail (due to offline state, sandbox constraints, or missing assets), the threads dynamically generate a fallback cover featuring the GOverlay logo using LCL Canvas drawing methods. Under Qt5/Qt6 on Linux, Canvas drawing in a background thread is not thread-safe and causes a deadlock with the main thread, freezing the entire application startup.

## What Changes

- Modify `TCoverDownloadThread` and `TNonSteamCoverThread` to execute `GenerateFallbackCover` on the main thread via `Synchronize`, rather than calling it directly inside the background thread.
- Ensure that no other non-thread-safe graphic drawing calls are performed inside the background threads.

## Capabilities

### New Capabilities

<!-- None -->

### Modified Capabilities

- `fallback-web-search-covers`: Add a constraint specifying that the generation of fallback covers must be executed thread-safely on the main GUI thread to avoid application deadlocks.

## Impact

- `games_tab.pas`: Refactor `TCoverDownloadThread.Execute` and `TNonSteamCoverThread.Execute` to use LCL thread synchronization for fallback cover generation.
