## Why

In Unreal Engine games, `bgmod` automatically locates the game's actual executable binary directory by detecting the presence of the `Engine` folder and recursively searching for subfolders containing `Binaries/Win64/*.exe`. 

However, some Unreal Engine games (such as *Deep Rock Galactic: Rogue Core*) package crash or bug reporting utilities in root subfolders like `BugReportClient` or `CrashReportClient`. Since the recursive directory search currently only ignores `Engine`, it traverses alphabetical subfolders and detects `BugReportClient` first, incorrectly copying all OptiScaler DLLs into the bug reporter's binaries folder instead of the actual game's binary folder (`RogueCore`). This prevents OptiScaler from loading.

## What Changes

- Update `FindUEShippingExe` in both `bgmod.lpr` and `bgmod-uninstaller.lpr` to ignore folders named `BUGREPORTCLIENT` and `CRASHREPORTCLIENT` (case-insensitively).

## Capabilities

### New Capabilities

*(None)*

### Modified Capabilities

- `bgmod-update-optiscaler`: Requirements for locating the game executable directory must exclude crash and bug reporting directories.

## Impact

- Affected files: `bgmod.lpr`, `bgmod-uninstaller.lpr`
- Affected components: OptiScaler game installer (`bgmod`) and uninstaller (`bgmod-uninstaller`).
- Backward compatibility: Fully preserved. No change to external APIs or configuration file structure.
