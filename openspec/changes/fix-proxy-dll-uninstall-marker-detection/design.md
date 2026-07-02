## Context

Both `bgmod` (the launch wrapper at `bgmod.lpr`) and `bgmod-uninstaller` (the standalone uninstaller at `bgmod-uninstaller.lpr`) need to decide, for a proxy DLL sitting in the game's installation directory, whether it was placed there by GOverlay (and should be cleaned up) or whether it belongs to a third-party tool the user installed (and must be preserved). The current mechanism — `IsGOverlayProxyFile` — compares the file size of the proxy DLL in `GameDir` against `bgmod/renames/<name>.dll` and `bgmod/OptiScaler.dll` paths derived from `GetBGModPath()`, which point at the global pristine template (stable channel). 

This size-check is fragile for two reasons:

1. **Channel mismatch.** `bgmod` installs a proxy DLL into `GameDir` from `SourceDir = gameconfig/<game>/renames/<name>.dll` (or `OptiScaler.dll` for non-prefixed names). For a bleeding-edge install, the size of that DLL differs from the stable `bgmod/renames/<name>.dll`, so `IsGOverlayProxyFile` returns false and the uninstaller refuses to delete the file, leaving the game loading OptiScaler even after the user clicked Uninstall.
2. **Stable-by-coincidence.** For the stable channel the check only works because `SourceDir` and the comparison path happen to point at the same underlying template (when `gameconfig/global/` is a mirror of `bgmod/`). If the global pristine is ever re-extracted to a newer minor build without updating every game folder, the size would also drift and stable cleanup would silently break.

The install flow already writes `goverlay.vars` to `GameDir` (`bgmod.lpr:935` `SafeCopyFile(ConfigDir + 'goverlay.vars', ...)` and `bgmod.lpr` install path also copies `goverlay.vars` as the last step). The presence of `goverlay.vars` in the same directory as the proxy DLL is a stronger, channel-agnostic ownership signal: GOverlay wrote both files together.

## Goals / Non-Goals

**Goals:**
- Replace `IsGOverlayProxyFile`'s size-comparison logic with a marker-based rule: a proxy DLL (per `IsProxyDllName`) without a `.b` backup is GOverlay-owned if `goverlay.vars` exists in the same directory.
- Apply the new logic identically to both `bgmod.lpr` (launch-wrapper disabled-cleanup path) and `bgmod-uninstaller.lpr`.
- Keep the third-party safety: when `goverlay.vars` is absent, proxy DLLs without `.b` are still treated as third-party and preserved.

**Non-Goals:**
- Changing the backup/restore semantics of `SafeCleanOrRestore` (the `.b` restore path is unchanged).
- Adding the `goverlay.vars` marker to GameDir when missing — `bgmod` already writes it on install; the GUI uninstaller (`games_tab.pas` `GameCardUninstallClick`) walks the tree and finds GameDirs via `goverlay.vars` markers, so any GameDir reached by the uninstaller already has the marker.
- Redesigning the overall uninstall architecture — only the ownership decision is in scope.
- Handling the case where the user manually deletes `goverlay.vars` from the GameDir but keeps the proxy DLL (out of scope; documented as a known limitation).

## Decisions

### 1. Marker-based ownership via `goverlay.vars`

`IsGOverlayProxyFile(TargetDir, FileName)` SHALL return `True` when the file is a known proxy DLL name (per the existing `IsProxyDllName` list) **and** `goverlay.vars` exists in `TargetDir`. The function no longer performs a size comparison against `bgmod/` or any per-game config dir.

Rationale: `goverlay.vars` is written into `GameDir` by `bgmod` at install time (the install block always ends with `SafeCopyFile(ConfigDir + 'goverlay.vars', ...)`). It is therefore a sufficient and necessary signature that GOverlay installed the proxy DLLs in that directory, irrespective of whether the channel was stable or bleeding-edge or whether the pristine template has since been re-extracted.

**Alternative considered:** compare against `gameconfig/<game>/renames/<name>.dll` instead of `bgmod/renames/<name>.dll`. Rejected: still a size comparison, still fragile if the user later switches channels and the game folder hasn't been re-synced. The marker approach is version-agnostic.

**Alternative considered:** always delete proxy DLLs without `.b` (option C in exploration). Rejected: would nuke legitimate third-party proxy DLLs (ReShade, RTSS, etc.) that share the same well-known proxy names.

### 2. Function signature and call sites unchanged

`IsGOverlayProxyFile(TargetDir, FileName: string): Boolean` keeps its signature. Only the body changes. All existing call sites (`SafeCleanOrRestore` in both binaries, and the disabled cleanup block in `bgmod.lpr`) continue to invoke it exactly as today. This keeps the blast radius small.

### 3. Remove dead size-comparison helpers

After the change, `GetFileSize` and the `BgmodPath`/`GlobalPath` lookups inside `IsGOverlayProxyFile` are no longer used by that function. They are still referenced by surrounding code (`NeedsLocalUpdate` in `bgmod.lpr` uses `GetFileSize`), so the helpers stay in the unit but the size-comparison branches inside `IsGOverlayProxyFile` are deleted.

### 4. Preserve `IsProxyDllName` semantics

`IsProxyDllName` continues to return true only for `dxgi.dll`, `winmm.dll`, `dbghelp.dll`, `version.dll`, `wininet.dll`, `winhttp.dll`. This is the gating list that prevents the marker rule from sweeping up arbitrary original game DLLs that happen to live next to `goverlay.vars`. Non-proxy DLLs continue to be handled by their `IsOriginalGameFile=True` branch in `SafeCleanOrRestore` (restore `.b` if present, otherwise delete), which is unaffected.

## Risks / Trade-offs

- **[Risk] User deletes `goverlay.vars` from GameDir but leaves the proxy DLL.** The proxy DLL would then be misclassified as third-party and not removed by a subsequent uninstall. *Mitigation:* the GUI uninstaller (`games_tab.pas` `GameCardUninstallClick`) walks the game tree using `goverlay.vars` as one of its marker files (`MarkerFiles := FindAllFiles(GamePath, 'goverlay.vars', True)`), so any GameDir reached by the uninstaller already contains the marker. The manual-delete case is an accepted limitation, documented in the proposal's Risks section.
- **[Risk] Multiple tools write `goverlay.vars` to the same directory.** Not realistic — `goverlay.vars` is a GOverlay-specific filename and is not used by other tools. The collision risk is effectively zero.
- **[Trade-off] The marker is now the authoritative signal, so its presence/absence is load-bearing.** Acceptable because `bgmod` always writes it as the last step of the install block and never deletes it mid-install. The disabled-cleanup path in `bgmod.lpr` explicitly removes it only after a successful cleanup, never before.
- **[Risk] Existing GameDirs with leftover edge proxy DLLs from a previously failed uninstall.** Those GameDirs still have `goverlay.vars` present (the failed uninstall preserved it because the DLL size check failed before reaching the `goverlay.vars` delete step). So the next uninstall after this fix will correctly classify the proxy DLLs as GOverlay-owned and remove them. No extra migration logic is required.

## Open Questions

- Should the `bgmod`/`bgmod-uninstaller` binaries be bumped in `data/bgmod/` as part of the same change, or shipped in a follow-up packaging update? The current implementation tasks assume a rebuild of both binaries and copying into `data/bgmod/`, but the exact packaging workflow is out of scope for this design and can be confirmed at task time.