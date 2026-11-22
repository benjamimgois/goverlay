# bgmod-launcher-resolution Specification

## Purpose
Provides reliable, case-insensitive game launcher target executable resolution and correct Wine DLL override environment variable formatting in `bgmod` and `bgmod-uninstaller`.

## Requirements

### Requirement: Case-insensitive launcher substitution
The `bgmod` and `bgmod-uninstaller` executables SHALL evaluate launcher substitution rules case-insensitively for both the game identifier key and the launcher executable filename.

#### Scenario: Launching game with lowercase launcher binary name
- **WHEN** a game is launched via an external store or runner (such as Epic Games or Heroic) where the launcher executable has different casing than the rule definition (e.g., `redprelauncher.exe` vs `REDprelauncher.exe`)
- **AND** a matching launcher rule exists in `bgmod.conf` or the built-in launcher defaults
- **THEN** `ResolveGameDirectory` matches the launcher argument case-insensitively, substitutes the target executable path, and resolves `GameDir` to the actual game binary directory.

#### Scenario: Parity in bgmod-uninstaller
- **WHEN** `bgmod-uninstaller` executes for a game launched via a lowercase launcher executable
- **THEN** `bgmod-uninstaller` matches the launcher rule case-insensitively and targets the correct game binary directory for uninstallation and cleanup.

### Requirement: Semicolon delimiter for Wine DLL overrides
The `bgmod` wrapper SHALL format multiple entries in the `WINEDLLOVERRIDES` environment variable using a semicolon (`;`) delimiter, adhering strictly to Wine's configuration syntax.

#### Scenario: Appending ReShade override to existing overrides
- **WHEN** `bgmod` prepares the environment for a Wine game and `WINEDLLOVERRIDES` already contains an override (such as `d3dcompiler_47=n,b`)
- **AND** ReShade is configured with a proxy DLL (such as `dxgi.dll`)
- **THEN** `bgmod` sets `WINEDLLOVERRIDES` to `d3dcompiler_47=n,b;dxgi=n,b` using a semicolon as the delimiter.

#### Scenario: OptiScaler and ReShade coexisting with distinct overrides
- **WHEN** both OptiScaler (e.g. `version.dll`) and ReShade (e.g. `dxgi.dll`) are active in a Wine game
- **THEN** `WINEDLLOVERRIDES` separates the overrides with semicolons (e.g. `version=n,b;dxgi=n,b`), allowing Wine to recognize and load each DLL independently.

### Requirement: Merging custom launcher rules with built-in defaults
The `bgmod` and `bgmod-uninstaller` executables SHALL merge custom entries from the `[Launchers]` section of `bgmod.conf` with the built-in default launcher replacement rules, evaluating custom rules first while preserving built-in rules for remaining games.

#### Scenario: Custom launcher rule present alongside built-in games
- **WHEN** `bgmod.conf` defines a `[Launchers]` section containing a custom game rule
- **AND** the user launches a different game covered by the built-in default launcher list (e.g., `Cyberpunk 2077` with `REDprelauncher.exe`)
- **THEN** `bgmod` evaluates the custom rule first and still applies the built-in default rule for `Cyberpunk 2077`.

### Requirement: Heuristic launcher and real game executable detection
When no explicit `[Launchers]` rule matches the command-line `.exe` argument, `bgmod` and `bgmod-uninstaller` SHALL evaluate whether the incoming `.exe` is a launcher/bootstrapper or whether a higher-scoring game executable exists within the game installation root, and resolve `GameDir` and `TargetExeName` to the highest-scoring game executable.

#### Scenario: Unity game launched via Paradox or sub-directory launcher (e.g. Cities: Skylines II)
- **WHEN** a game is launched with a command-line argument pointing to a launcher executable (such as `Launcher/dowser.exe` or `Paradox Launcher.exe`)
- **AND** the game installation root (resolved via `STEAM_COMPAT_INSTALL_PATH` or parent directory inference) contains a Unity game executable accompanied by `UnityPlayer.dll` (or `GameAssembly.dll`) and a matching `<ExeName>_Data` folder
- **THEN** `bgmod` and `bgmod-uninstaller` reject the launcher executable and resolve `GameDir` and `TargetExeName` to the Unity game executable and its directory.

#### Scenario: Unreal Engine game launched via a launcher subfolder
- **WHEN** a game is launched via an executable inside a launcher subfolder (such as `Launcher/FuncomLauncher.exe`)
- **AND** the game installation root contains an Unreal Engine shipping executable under `<Project>/Binaries/Win64/`
- **THEN** `bgmod` and `bgmod-uninstaller` climb to the installation root, detect the Unreal Engine shipping binary, and resolve `GameDir` and `TargetExeName` to `<Project>/Binaries/Win64/` and its shipping `.exe`.

#### Scenario: Candidate scoring prioritizes directory with native upscaler DLLs and 3D PE imports
- **WHEN** an installation root contains both a bootstrapper/launcher executable (or CEF/Qt launcher with `libcef.dll` / `Qt5Core.dll` / `Qt6Core.dll`) and a game executable in a subdirectory (such as `bin/`, `bin/x64/`, `Retail/`, or `binaries/`)
- **AND** the game executable imports 3D graphics APIs (`d3d12.dll`, `d3d11.dll`, `dxgi.dll`, `d3d9.dll`, or `opengl32.dll`) or shares its directory with native upscaler DLLs (`nvngx_dlss*.dll`, `libxess*.dll`, `amd_fidelityfx_*.dll`, `sl.interposer.dll`)
- **THEN** the candidate scoring system selects the 3D game executable directory over the launcher directory.

#### Scenario: Direct game executable without launcher remains unchanged
- **WHEN** a game is launched directly with its real game `.exe` (not a launcher, and no higher-scoring candidate exists in the installation tree)
- **THEN** `bgmod` and `bgmod-uninstaller` keep the original executable's directory and filename.
