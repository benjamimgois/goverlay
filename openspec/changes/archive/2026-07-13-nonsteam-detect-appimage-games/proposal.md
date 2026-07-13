## Why

Many Linux games (such as fan games, source ports, and decompilation projects) are distributed as standalone `.appimage` executable files rather than inside subdirectories. Currently, GOverlay's non-Steam games tab only scans and lists subdirectories inside the configured non-Steam folders, ignoring individual AppImage files. Allowing GOverlay to recognize `.appimage` files as games expands the utility of the non-Steam tab to a much wider variety of Linux games.

## What Changes

- Scan for files with `.appimage` (or `.AppImage`) extensions inside the user's non-Steam games directories.
- Create game card panels for detected AppImage files.
- Clean and normalize the AppImage filename to extract a human-readable game name, which serves as the unique identifier for the game configuration folder (e.g. `Dusklight-v1.4.1-linux-x86_64.appimage` maps to `Dusklight` as the game name).
- Pass the full path of the AppImage file as the `SubPath` (which is shown in the card panel's mouse-hover tooltip).

## Capabilities

### New Capabilities
- `nonsteam-detect-appimage-games`: Detect, map, and clean game names from AppImage executables inside non-Steam directories.

### Modified Capabilities
<!-- None -->

## Impact

- `games_tab.pas`: Update `LoadNonSteamFolders` scanning loop to accept `.appimage` files, and implement a `NormalizeAppImageName` helper function to extract clean game names from filenames.
