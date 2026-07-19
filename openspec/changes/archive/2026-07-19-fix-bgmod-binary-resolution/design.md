## Context

To comply with the Filesystem Hierarchy Standard (FHS), the compiled binaries `bgmod` and `bgmod-uninstaller` were moved from the shared architecture-independent `/usr/share/goverlay/bgmod/` folder to `/usr/libexec/goverlay/` (system installs) or `AppDir/lib/` (AppImage builds). However, `InitializeBGModDirectory` in `bgmod_resources.pas` assumes the binaries are always located in the same directory as the GOverlay executable (`ExtractFilePath(ParamStr(0))`). When running GOverlay in environments where these paths differ (such as inside the AppImage, or package configurations where `goverlay` is in `/usr/bin`), the binary copy fails, preventing the automatic installation of OptiScaler on startup.

## Goals / Non-Goals

**Goals:**
- Dynamically resolve the directory containing the compiled helper binaries (`bgmod` and `bgmod-uninstaller`) across multiple environments (local development, native package installation, and AppImage builds).
- Ensure the binaries are copied to the active configuration directory (`~/.local/share/goverlay/bgmod/`) on startup.

**Non-Goals:**
- Changing how the template files (like `bgmod.conf`, `LICENSE`, etc.) are packaged or resolved.
- Modifying how OptiScaler DLLs are downloaded or extracted in the cache directory.

## Decisions

### 1. Multi-candidate path resolver helper
We will introduce a helper function `GetBGModBinariesSourceDir: string` in `bgmod_resources.pas` that scans the following candidate directories in order:
1. `BinaryDir` (executable directory, covers native system installs under `/usr/libexec/` and development environments).
2. Relative `lib/` directory: `ExtractFilePath(ExcludeTrailingPathDelimiter(BinaryDir)) + 'lib'` (covers standard packaging structure).
3. The path in `GetEnvironmentVariable('APPDIR') + '/lib'` (specifically for AppImage builds where `bgmod` is located in `AppDir/lib/`).

### 2. Update Cópia in `InitializeBGModDirectory`
In `InitializeBGModDirectory`, instead of using `BinaryDir := ExtractFilePath(ParamStr(0))` directly in the `cp` command, we will call `GetBGModBinariesSourceDir` to resolve the source folder. If found, we will execute the copy process. If not found, we will log a warning.

## Risks / Trade-offs

- **[Risk]** If no binaries are found, GOverlay starts but `IsBGModInitialized` returns `False`, skipping OptiScaler auto-install.
  - *Mitigation*: We will log a clear warning to stdout/stderr: `[BGMOD] WARNING: Compiled bgmod templates not found in any candidate directory!`.
