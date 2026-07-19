## ADDED Requirements

### Requirement: Robust path resolution for bgmod template binaries
During the initialization of the local configuration directory (`InitializeBGModDirectory`), GOverlay SHALL locate the template binaries (`bgmod` and `bgmod-uninstaller`) by checking the following candidate locations:
1. GOverlay's executable directory (`ExtractFilePath(ParamStr(0))`).
2. GOverlay's executable directory's relative `lib/` directory.
3. The directory specified by the `$APPDIR` environment variable, specifically under `$APPDIR/lib/` (for AppImage compatibility).

If found in any of these candidate locations, GOverlay SHALL copy them to the local `bgmod/` configuration directory.

#### Scenario: AppImage environment path resolution
- **WHEN** GOverlay is executed inside an AppImage, and the template binaries exist in `/tmp/.mount_XXXXXX/lib/`
- **THEN** GOverlay successfully copies `bgmod` and `bgmod-uninstaller` to `~/.local/share/goverlay/bgmod/`.

#### Scenario: Source development directory resolution
- **WHEN** GOverlay is run from the source root directory, and the compiled `bgmod` and `bgmod-uninstaller` exist in the same root directory
- **THEN** GOverlay successfully copies `bgmod` and `bgmod-uninstaller` to `~/.local/share/goverlay/bgmod/`.
