# Design

## Context

See proposal.md - Why.
`bgmod` manages runtime DLL injection for upscalers (OptiScaler, DLSS Enabler, HelixSR) and ReShade. Both store state in `goverlay.vars` in the game directory. Currently, `bgmod`'s cleanup path for disabled OptiScaler triggers if `goverlay.vars` exists for any reason (even if created solely by ReShade), and deletes non-backed-up DLLs in `OrigDlls` and proxies matching `bgmod.conf`.

## Goals / Non-Goals

**Goals:**
- Guarantee that ReShade-only game configurations never invoke OptiScaler DLL cleanup passes.
- Protect all native game DLLs (`nvngx_dlss*.dll`, `sl.*.dll`, `amd_fidelityfx_loader_dx12.dll`) from deletion during cleanup when backups do not exist.
- Protect third-party mod files and mod managers (`version.dll` for CET, `OptiScaler/` folders managed by Vortex).
- Enable launcher detection for games whose directory name omits spaces (e.g. `Cyberpunk2077`).

**Non-Goals:**
- Changing ReShade runtime injection mechanism.
- Modifying how OptiScaler creates backups on initial installation.
- Overhauling `bgmod.conf` format.

## Decisions

### 1. OptiScaler Leftover Cleanup Gating
- *Decision*: In `bgmod.lpr`, replace the generic `FileExists(GameDir + 'goverlay.vars')` check with a specific function `HasOptiScalerLeftovers(const GameDir: string): Boolean`. This checks:
  1. `goverlay.vars` containing OptiScaler keys: `proxydll`, `upscalertype`, `dlssenablerversion`, or `fsrversion`.
  2. Existence of known OptiScaler binary files: `OptiScaler.dll`, `OptiScaler.ini`, `fakenvapi.dll`.
  If only `reshadeproxy` exists in `goverlay.vars`, the function returns `False`.
- *Rationale*: ReShade writes `reshadeproxy` to `goverlay.vars`. Relying on file existence alone triggered cleanup on every single launch after ReShade was enabled.
- *Alternatives Considered*: Storing ReShade metadata in a separate file (e.g. `reshade.vars`). Rejected because existing installations and uninstaller routines rely on `goverlay.vars` for `reshadeproxy`.

### 2. Guarding `SafeCleanOrRestore` for Non-Backed-Up Game DLLs
- *Decision*: When iterating `OrigDlls` during cleanup or uninstallation:
  If a file does not have a backup in `BackupsDir`, it MUST NOT be deleted unless it matches the exact file size of a known GOverlay payload in `SourceDir`. If no backup exists and size does not match `SourceDir`, it is treated as a native game file (`IsOriginalGameFile = True`), preserving it intact.
- *Rationale*: Games supporting DLSS 3 / Frame Generation ship native `nvngx_dlss*.dll` and `sl.*.dll`. If OptiScaler was never installed or never replaced them, no backup exists in `backups/`. Treating absence of backup as "safe to delete" permanently corrupted games.
- *Alternatives Considered*: Adding all Streamline and DLSS DLLs to `IsNativeGameDll`. While helpful, adding them alone without the payload check would prevent removing GOverlay-introduced DLLs on games that originally had no Streamline DLLs. The payload size check provides exactness.

### 3. Payload-Based Verification in `IsGOverlayProxyFile`
- *Decision*: When checking fallback `bgmod.conf` `DLL=` setting in `IsGOverlayProxyFile`, do not return `True` solely based on string equality. Before concluding the proxy belongs to GOverlay, verify that the file in `TargetDir` matches the file size of the corresponding proxy binary in GOverlay's source or data directories (`BgmodPath`, `SourceDir`, or XDG data directories). If size does not match, log that a third-party proxy was detected and return `False`.
- *Rationale*: Popular mod loaders (like Cyber Engine Tweaks in Cyberpunk 2077) use `version.dll`. When Goverlay has `DLL=version.dll` in config, it blindly deleted CET.

### 4. Protecting Externally Managed `OptiScaler/` Folders
- *Decision*: Before calling `SafeDeleteDirectory(GameDir + 'OptiScaler')`, check if markers like `__folder_managed_by_vortex` exist, or if the directory contains files unknown to GOverlay. If so, skip folder deletion and only remove known GOverlay files inside it.
- *Rationale*: Vortex and manual mod managers install mods into `OptiScaler/`. Wiping the entire folder destroyed user mod installations.

### 5. Flexible Launcher Rule Directory Matching
- *Decision*: In `ResolveGameDirectory`, normalize spaces in directory matching so both `Cyberpunk 2077` and `Cyberpunk2077` match the rule `Cyberpunk 2077=REDprelauncher.exe|bin/x64/Cyberpunk2077.exe`.
- *Rationale*: Heroic Games Launcher installs GOG releases to folder names without spaces, breaking launcher redirection.

## Risks / Trade-offs

- **[Risk]** A user with a modified/rebuilt OptiScaler DLL whose size differs from GOverlay's package might not be cleaned up if no backup exists.
  → *Mitigation*: If `proxydll` is explicitly recorded in `goverlay.vars`, the primary tier in `IsGOverlayProxyFile` still identifies it. Size fallback only applies to unrecorded/ambiguous files.
- **[Risk]** Residual Streamline DLLs on games where DLSS Enabler was installed but the files matched nothing.
  → *Mitigation*: DLSS Enabler creates backups when installed; if backups exist, restoration still functions normally.
