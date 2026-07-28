## Context

AppImage builds of GOverlay crash on startup during `CheckForUpdatesOnClick` with an uncaught `EThread` exception: "Failed to create new thread."
This issue stems from thread management incompatibilities under Linux when using Free Pascal + Qt6 without the C memory manager (`cmem`), coupled with a lack of defensive exception handling when spawning `TThread` subclasses.

## Goals / Non-Goals

**Goals:**
- Ensure `goverlay.lpr` uses `cmem` for UNIX targets to align FPC memory management with glibc and Qt6 thread operations.
- Wrap background thread spawns (e.g. `TOptiUpdateThread.Create`) in defensive `try ... except` blocks so that thread creation failures fail gracefully without popping up modal error dialogs or crashing the app.

**Non-Goals:**
- Refactoring the entire threading model of GOverlay.

## Decisions

### Decision 1: Add `cmem` to `goverlay.lpr`
In Free Pascal on Linux, using `cthreads` without `cmem` when interfacing with Qt6/C libraries can lead to heap and thread initialization failures. Adding `cmem` prior to `cthreads` in `goverlay.lpr` redirects heap allocations to `glibc` `malloc`/`free`, which is required for Qt6 C/C++ library interoperability.

### Decision 2: Guard `TOptiUpdateThread.Create` with `try ... except`
In `optiscaler_update.pas`, wrap the `TOptiUpdateThread.Create` call in a `try ... except` block. If thread creation fails due to system OS limits or runtime container restrictions, log the warning to stdout and safely set `FUpdateThread := nil`.

## Risks / Trade-offs

- [Risk]: Including `cmem` could affect memory tracking in debug builds if debug heaptrc is used.
- [Mitigation]: Limit `cmem` to standard `UNIX` builds as intended by FPC guidelines.
