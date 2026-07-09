## Context

In GOverlay, the launcher wrapper (`bgmod`) and uninstaller (`bgmod-uninstaller`) are compiled Free Pascal programs that manage OptiScaler configuration and file installation. To support Unreal Engine games (which typically structure binaries under `<GameDir>/<ProjectName>/Binaries/Win64`), both utilities contain a recursive search function `FindUEShippingExe` that attempts to find directories containing `Binaries/Win64/*.exe`. 

However, this function currently only ignores the folder `Engine` during recursion. Unreal Engine games that include crash reporting or bug reporting utilities in subdirectories like `BugReportClient` or `CrashReportClient` are misidentified because those subdirectories contain `Binaries/Win64/*.exe` and are traversed first (due to alphabetical sorting). This causes OptiScaler DLLs to be copied into the crash reporter's folder rather than the actual game binaries folder.

## Goals / Non-Goals

**Goals:**
- Update `FindUEShippingExe` to ignore directories named `BUGREPORTCLIENT` and `CRASHREPORTCLIENT` case-insensitively during recursive directory scanning.
- Ensure OptiScaler DLLs are copied to the correct binaries folder in "Deep Rock Galactic: Rogue Core" and other similarly packaged games.
- Ensure that the uninstaller correctly cleans up files in the actual game directory rather than the crash reporter directory.

**Non-Goals:**
- Changing configuration file structure.
- Re-architecting how game detection is performed.

## Decisions

### Decision: Filter utility directories in FindUEShippingExe
We will update the directory recursion loop in `FindUEShippingExe` in both `bgmod.lpr` and `bgmod-uninstaller.lpr` to ignore `BUGREPORTCLIENT` and `CRASHREPORTCLIENT`.

*Alternative 1 (Rejected)*: Check if the executable name contains `Shipping`.
*Why Rejected*: Not all game binaries use the `-Win64-Shipping.exe` suffix, especially if developers name their binary customly or run in different packaging configurations.
*Alternative 2 (Rejected)*: Use `Pos` to exclude any directory name containing `Report`.
*Why Rejected*: Risky because valid game project folders could contain the string "Report" or "Bug" (e.g. "Bugsnax", "ReportFromHell"), leading to false negatives. Exclude list is safer.

## Risks / Trade-offs

- **Risk**: A future game might use a different name for its custom bug reporter client.
- **Mitigation**: Add the most common ones (`BUGREPORTCLIENT`, `CRASHREPORTCLIENT`). If another specific folder is found, we can add it to the exclusion list.
