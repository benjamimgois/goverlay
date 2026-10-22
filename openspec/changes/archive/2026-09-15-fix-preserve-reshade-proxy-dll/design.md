## Context

`bgmod` and `bgmod-uninstaller` manage proxy DLLs (`dxgi.dll`, `winmm.dll`, `dbghelp.dll`, `version.dll`, `wininet.dll`, `winhttp.dll`, `d3d12.dll`) used by OptiScaler and DLSS Enabler. When OptiScaler is active, `bgmod` loops through all known proxy DLL names and attempts to clean up inactive proxies so that switching proxies (e.g., from `dxgi.dll` to `d3d12.dll`) doesn't leave an old GOverlay proxy DLL conflicting with the game.

Currently, `IsGOverlayProxyFile` tests:
```pascal
function IsGOverlayProxyFile(const TargetDir, FileName: string): Boolean;
begin
  Result := False;
  if not IsProxyDllName(FileName) then Exit;
  Result := FileExists(IncludeTrailingPathDelimiter(TargetDir) + 'goverlay.vars');
end;
```
Because `goverlay.vars` is always present in the game directory when GOverlay manages that game, any third-party proxy DLL (such as ReShade's `dxgi.dll`) is falsely treated as GOverlay-owned and deleted whenever OptiScaler is configured to use a different proxy DLL (e.g. `d3d12.dll`).

## Goals / Non-Goals

**Goals:**
- Explicitly track the active proxy DLL installed by GOverlay in `goverlay.vars` (`proxydll=<name>`).
- Enhance `IsGOverlayProxyFile` in both `bgmod.lpr` and `bgmod-uninstaller.lpr` with a two-tier verification check:
  1. Primary: match against the recorded `proxydll` in `goverlay.vars`.
  2. Fallback: match file size against source OptiScaler / proxy DLLs across cache directories if `proxydll` is unrecorded (legacy installs).
- Preserve third-party proxy DLLs (like ReShade, SpecialK) across game launches, proxy switches, OptiScaler disablement, and uninstallation.

**Non-Goals:**
- Modifying non-proxy DLL handling (such as `nvngx.dll` or `sl.*.dll`), which already use dedicated backup-restore mechanisms.
- Auto-configuring or injecting third-party tools like ReShade.

## Decisions

### Decision 1: Record `proxydll` in `goverlay.vars`
- **Choice:** When `bgmod` installs the active proxy DLL (e.g. `d3d12.dll` or `dxgi.dll`), it calls `WriteVarToFile(..., 'proxydll', DllName)` in `GameDir/goverlay.vars`.
- **Rationale:** Explicit metadata provides an authoritative record of which proxy DLL belongs to GOverlay, eliminating ambiguity when multiple proxy DLLs exist in the game folder.
- **Alternative considered:** Relying only on file size comparison. Rejected because bleeding-edge, edge updates, or custom OptiScaler builds have variable sizes that can lead to false negatives across channel changes.

### Decision 2: Two-tier ownership verification in `IsGOverlayProxyFile`
- **Choice:**
  1. Read `proxydll` from `goverlay.vars`. If present:
     - If `SameText(RecordedProxy, FileName)` is true, return `True`.
     - Otherwise, return `False` (the file belongs to another mod/tool, skip deletion).
  2. If `proxydll` is empty (legacy install without the key):
     - Compare `GetFileSize(TargetFile)` with candidate OptiScaler DLLs from local/global cache and source directories. Return `True` only if an exact size match is found.
- **Rationale:** Guarantees zero false positives for third-party mods while maintaining backwards compatibility for existing installations.
- **Alternative considered:** Keeping the unconditional `goverlay.vars` existence check. Rejected as this is the exact root cause of deleting ReShade's `dxgi.dll`.

### Decision 3: Mirror logic in `bgmod-uninstaller.lpr`
- **Choice:** Update `IsGOverlayProxyFile` and the proxy cleanup loop in `bgmod-uninstaller.lpr` with the exact same two-tier verification.
- **Rationale:** Ensures that running the uninstaller or selecting "Uninstall changes" also respects and preserves third-party proxy DLLs.

## Risks / Trade-offs

- **[Risk]** A third-party DLL happens to have the exact same file size as OptiScaler's DLL on a legacy installation before `proxydll` is written.
  - *Mitigation:* Compiled ReShade DLLs typically differ significantly in size from OptiScaler DLLs. Furthermore, the first time the game launches under the updated `bgmod`, `proxydll` is recorded immediately, preventing future size comparisons.
