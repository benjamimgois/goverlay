## Why

When running the AppImage version of GOverlay nightly builds, background thread creation fails on startup during `CheckForUpdatesOnClick` with an uncaught `EThread` exception: "Failed to create new thread."
This happens because Free Pascal on Linux requires `cmem` memory manager when using Qt6 + multi-threading, and because thread creation is missing defensive `try ... except` error handling.

## What Changes

- Add `cmem` before `cthreads` in `goverlay.lpr` to ensure C/Qt6 thread-safe memory management.
- Wrap background thread instantiation (such as `TOptiUpdateThread.Create`) in defensive `try ... except` blocks so that thread creation failure degrades gracefully without crashing the UI.
- Verify AppImage build script configuration in `appimage/goverlay-appimage.sh`.

## Capabilities

### New Capabilities
- None

### Modified Capabilities
- None

## Impact

- `goverlay.lpr`: Includes `cmem` unit for UNIX builds.
- `optiscaler_update.pas`: Protects `TOptiUpdateThread.Create` with `try ... except`.
