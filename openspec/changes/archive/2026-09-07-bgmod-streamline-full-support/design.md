## Context

See proposal.md - Why.
`bgmod` acts as the launcher wrapper and runtime injector for OptiScaler and DLSS Enabler. For games that ship with Streamline, partially replacing some Streamline DLLs while leaving others (like `sl.pcl.dll`) causes crashes due to ABI incompatibilities between different Streamline SDK releases (such as 2.4 vs 2.12).

## Goals / Non-Goals

**Goals:**
- Include all Streamline SDK DLLs in `OrigDlls` in `bgmod.lpr` to support backup and uninstallation restoration.
- Ensure all available Streamline DLLs in `SourceDir` are copied to `GameDir` when DLSS Enabler is enabled.
- Ensure proper cleanup of non-native Streamline DLLs when DLSS Enabler is disabled.
- Recompile `bgmod` binary and verify through automated tests.

**Non-Goals:**
- Modifying Streamline SDK binaries directly.
- Overwriting non-Streamline native DLLs.

## Decisions

1. **Include Streamline DLLs in `OrigDlls`**
   - *Decision*: Add `sl.common.dll`, `sl.deepdvc.dll`, `sl.directsr.dll`, `sl.dlss.dll`, `sl.dlss_d.dll`, `sl.dlss_g.dll`, `sl.imgui.dll`, `sl.interposer.dll`, `sl.nis.dll`, `sl.nvperf.dll`, `sl.pcl.dll`, `sl.reflex.dll` to `OrigDlls`.
   - *Rationale*: When `bgmod` initializes, any DLL listed in `OrigDlls` that exists in `GameDir` is safely copied to `backups/<dll>` before any mod files are written. On uninstall or when OptiScaler/DLSS Enabler is toggled off, `SafeCleanOrRestore` restores the backed-up file or deletes the file if it was not present originally.
   - *Alternative Considered*: Only copying `sl.pcl.dll` without adding to `OrigDlls`. Rejected because games with native Streamline would lose their original DLLs upon disabling the mod.

2. **Loop-based deployment of Streamline libraries**
   - *Decision*: Define a constant array of Streamline DLLs in `bgmod.lpr` or iterate over them using `SafeCopyFile`.
   - *Rationale*: Guarantees all 12 Streamline DLLs are consistently copied if present in `SourceDir`, preventing any partial version mismatches.

## Risks / Trade-offs

- [Risk] Game directory might accumulate unused Streamline plugins.
  → *Mitigation*: Only copy plugins that actually exist in `SourceDir` (`dlssenabler-stable` / `dlssenabler-edge`). On cleanup, restore or remove according to `backups/`.
