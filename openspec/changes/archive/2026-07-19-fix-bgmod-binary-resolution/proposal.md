## Why

When running GOverlay from certain environments—such as an AppImage where the main binary resides in `AppDir/bin/` and template binaries are in `AppDir/lib/`, or under custom distribution packages—GOverlay fails to locate and copy the `bgmod` and `bgmod-uninstaller` executables to the local configuration directory (`~/.local/share/goverlay/bgmod/`). This prevents `IsBGModInitialized` from succeeding, which in turn causes the application to silently bypass the automatic installation of OptiScaler on startup.

## What Changes

- Modify `InitializeBGModDirectory` in `bgmod_resources.pas` to resolve the source folder of `bgmod` and `bgmod-uninstaller` by checking multiple candidate locations (the executable directory, relative `lib` directories, and the AppImage `APPDIR` environment variable).
- Clean up any legacy or duplicate checks that assume the template executables are only located in the same directory as the GOverlay binary.

## Capabilities

### New Capabilities

<!-- None -->

### Modified Capabilities

- `bgmod-update-optiscaler`: Extend the executable path resolution requirements for `bgmod` and `bgmod-uninstaller` to support scanning multiple directory candidates, including `$APPDIR/lib/` and relative `lib/` paths.

## Impact

- `bgmod_resources.pas`: Update `InitializeBGModDirectory` resolution and copy logic.
