## Context

Currently, the non-Steam tab scans subfolders inside the user-configured directories but skips files. Several Linux games (especially ports and decompilation projects) are distributed as single AppImage executables. Treating AppImage files as folders for configuration purposes is completely safe since GOverlay only interacts with the game configuration folders (under `~/.local/share/goverlay/gameconfig/`) and does not launch the files itself.

## Goals / Non-Goals

**Goals:**
- Detect files with `.appimage` or `.AppImage` extension inside non-Steam directories.
- Clean up the game name by stripping extension, platform, architecture, and version suffixes.
- Show the correct clean game name on the UI card label and the configuration folder name, while passing the absolute AppImage filepath as the `SubPath` for the tooltip.

**Non-Goals:**
- We do not run or execute the AppImage files from within GOverlay.
- We do not modify how Steam or local games are scanned.

## Decisions

### Decision 1: NormalizeAppImageName Helper
Implement a robust name cleanup function `NormalizeAppImageName` inside `games_tab.pas` that handles:
- Stripping `.appimage` and `.AppImage` extensions.
- Finding and removing substrings like `-linux`, `_linux`, `-x86_64`, `_x86_64`, `-x64`, and version patterns (such as `-vX.Y.Z` or `-X.Y.Z`).
- **Rationale**: Keeps configuration folders unified across game updates (so downloading `Dusklight-v1.4.2.appimage` shares settings with the previous `Dusklight-v1.4.1.appimage`).

### Decision 2: Modify FindFirst/FindNext Loop
Modify the `FindFirst` filter and the attributes checking block inside `TGamesTabHelper.LoadNonSteamFolders`.
- **Rationale**: Instead of strictly filtering out all files with `if (SubSR.Attr and faDirectory) = 0 then Continue;`, we check if the file extension is `.appimage` case-insensitively, setting a helper boolean `IsAppImage`.

## Risks / Trade-offs

- **[Risk]** Two AppImages in the same folder could resolve to the same game name.
  - *Mitigation*: GOverlay will render separate cards with the same visual name, which is acceptable and expected for separate versions.
