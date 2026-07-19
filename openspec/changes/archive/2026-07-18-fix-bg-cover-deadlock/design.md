## Context

When GOverlay is launched with empty configurations, the cover cache is empty, causing the background threads `TCoverDownloadThread` (for Steam games) and `TNonSteamCoverThread` (for non-Steam games) to run. If downloads fail, they invoke `GenerateFallbackCover`, which performs graphic canvas operations (`TBitmap`, `TCanvas`). Because LCL Canvas operations are not thread-safe on Linux under Qt5/Qt6, this results in a deadlock that freezes the main GUI loop.

## Goals / Non-Goals

**Goals:**
- Eliminate the startup freeze/deadlock when game covers fail to download.
- Ensure that `GenerateFallbackCover` is executed thread-safely on the main GUI thread.

**Non-Goals:**
- Refactoring the curl download logic or changing how fallback covers look.
- Rewriting image rendering with non-LCL libraries.

## Decisions

### Decision 1: Use LCL Thread Synchronization for Fallback Cover Generation
- **Choice**: Implement wrapper methods in `TCoverDownloadThread` and `TNonSteamCoverThread` that set `FCurrentPath` and call `Synchronize(@DoGenerateFallback)`.
- **Alternatives Considered**:
  - *Drawing on background thread using raw X11/Xlib/Wayland*: Too complex, architecture-dependent, and prone to compatibility issues.
  - *Using external image tools (e.g. ImageMagick/convert)*: Introduces an external dependency and is slow.
- **Rationale**: `Synchronize` is a native LCL/FPC mechanism designed to execute a method safely on the main GUI thread. Generating a fallback cover is extremely fast, so the small blocking overhead on the main thread is negligible.

## Risks / Trade-offs

- **[Risk]** Synchronizing many fallback calls on startup could briefly lag the UI.
  - *Mitigation*: Fallback cover generation only occurs when a download fails (or is offline). Generating the small bitmap takes less than 1ms. The main bottleneck of the thread is the curl network timeout, which runs asynchronously in separate processes and does not block the UI.
