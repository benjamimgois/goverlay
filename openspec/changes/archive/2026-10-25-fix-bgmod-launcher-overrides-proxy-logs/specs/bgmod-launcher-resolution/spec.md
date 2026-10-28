# Spec Delta

## Purpose

Provides reliable, case-insensitive game launcher target executable resolution and correct Wine DLL override environment variable formatting in `bgmod` and `bgmod-uninstaller`.

## ADDED Requirements

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
