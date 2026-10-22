## Why

When installing DLSS Enabler on games with native Streamline implementations (such as *God of War Ragnarök*), `bgmod` only copied a subset of Streamline DLLs, notably omitting `sl.pcl.dll` and auxiliary plugins. This resulted in an ABI mismatch between Streamline 2.12 and the game's original Streamline 2.4 `sl.pcl.dll`, causing immediate SIGABRT crashes upon calling latency markers. Furthermore, `sl.*.dll` files were omitted from `OrigDlls`, meaning native game files were neither backed up nor restored on uninstallation.

## What Changes

- Add all Streamline SDK DLLs (`sl.common.dll`, `sl.deepdvc.dll`, `sl.directsr.dll`, `sl.dlss.dll`, `sl.dlss_d.dll`, `sl.dlss_g.dll`, `sl.imgui.dll`, `sl.interposer.dll`, `sl.nis.dll`, `sl.nvperf.dll`, `sl.pcl.dll`, `sl.reflex.dll`) to `OrigDlls` in `bgmod.lpr` to guarantee native copies are backed up before replacement and cleanly restored when disabled.
- Expand the Streamline installation logic in `bgmod.lpr` to copy all available Streamline libraries from `SourceDir`, preventing version/ABI mismatch.
- Update cleanup routines in `bgmod.lpr` to remove or restore any Streamline SDK leftovers.
- Add comprehensive automated tests in `tests/gui/gui_test_cases.pas` verifying backup, deployment of the complete Streamline suite (including `sl.pcl.dll`), and uninstallation restoration.

## Capabilities

### New Capabilities
- `bgmod-streamline-full-support`: Complete Streamline SDK deployment, backup, and cleanup management in `bgmod`.

### Modified Capabilities
None.

## Impact

- `bgmod.lpr`: Streamline DLL arrays, installation, backup, and restoration logic.
- `tests/gui/gui_test_cases.pas`: Automated regression tests for Streamline backup, complete installation, and cleanup.
