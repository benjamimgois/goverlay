## Context

Currently, the `bgmod` and `bgmod-uninstaller` binaries are packaged and installed into `/usr/share/goverlay/bgmod/`. Placing architecture-dependent binaries under `/usr/share` violates the Filesystem Hierarchy Standard (FHS) and fails RPM packaging lint checks.

## Goals / Non-Goals

**Goals:**
- Move `bgmod` and `bgmod-uninstaller` to `/usr/libexec/goverlay/` upon system installation.
- Clean up `/usr/share/goverlay/bgmod/` to contain only architecture-independent files.
- Ensure GOverlay correctly locates and copies the binaries from `/usr/libexec/goverlay/` to the user's home directory.

**Non-Goals:**
- Moving non-binary template configuration files (`bgmod.conf`, etc.) out of `/usr/share/goverlay/bgmod/`.

## Decisions

### 1. Resolve binary location using GOverlay executable directory
- **Choice**: Copy `bgmod` and `bgmod-uninstaller` to the user's `~/.local/share/goverlay/.bgmod_original/` from `ExtractFilePath(ParamStr(0))` (the directory of the running GOverlay executable).
- **Rationale**: Since `goverlay` itself is installed in `/usr/libexec/goverlay/`, the directory of GOverlay's executable is guaranteed to contain the matching `bgmod` and `bgmod-uninstaller` binaries in production. This also works seamlessly in local development builds where all compiled binaries are generated in the repository root.

### 2. Update Makefile to install binaries to `libexecdir` and clean up `datadir`
- **Choice**: Modify the `Makefile`'s `install` target to call `install -m=755` on `bgmod` and `bgmod-uninstaller` to `$(DESTDIR)$(prefix)$(libexecdir)/`, and call `rm -f` to clean up these binaries from the `datadir` copy.
- **Rationale**: This is standard, compliant, and does not require complex changes to the packaging spec files, as they already configure `prefix` and `libexecdir`.

## Risks / Trade-offs

- **[Risk]** If a custom launch wrapper calls GOverlay from a different path (e.g. symlink) that changes the executable directory, `ParamStr(0)` directory resolution could fail.
  - *Mitigation*: The standard launch wrapper (`data/goverlay.sh`) executes `@libexecdir@/goverlay` directly. Additionally, GOverlay is typically launched via its absolute path in desktop entries.
