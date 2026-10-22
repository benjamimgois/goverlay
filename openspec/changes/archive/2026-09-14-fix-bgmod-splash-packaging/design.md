## Context

See `proposal.md` - Why.
When `make install` runs with `prefix=/usr libexecdir=/lib`, `bgmod-splash` is installed to `/usr/lib/bgmod-splash`. In addition, `data/bgmod/*` is copied to `/usr/share/goverlay/bgmod/`. The RPM build checks that every installed file is accounted for in `%files` and flags ELF binaries in `/usr/share`.

## Goals / Non-Goals

**Goals:**
- Add `bgmod-splash` to `%files` in `packaging/rpm/goverlay.spec` to fix the CI package build failure.
- Remove duplicate `bgmod-splash` binary from `/usr/share/goverlay/bgmod/` during `make install`.
- Bundle `bgmod-splash` into `AppDir/lib/` in `appimage/goverlay-appimage.sh`.

**Non-Goals:**
- Changes to `bgmod-splash` Pascal source code or UI behavior.
- Changes to Flatpak packaging (Flatpak already installs `bgmod-splash` cleanly).

## Decisions

### Decision 1: Declare `%{_prefix}/lib/bgmod-splash` in `packaging/rpm/goverlay.spec`
- **Rationale**: `make install` installs `bgmod-splash` alongside `bgmod`, `bgmod-uninstaller`, `pascube`, and `goverlay`. Declaring it under `%files` satisfies `rpmbuild`'s `check-files` test.
- **Alternatives Considered**: Suppressing `check-files` via RPM macro was rejected as it masks real packaging omissions.

### Decision 2: Prune `bgmod-splash` from `$(datadir)/goverlay/bgmod/` in `Makefile`
- **Rationale**: `Makefile` already prunes `bgmod` and `bgmod-uninstaller` from `$(datadir)` right after copying `data/bgmod/*`. `bgmod-splash` is an ELF binary and must not linger in `/usr/share`.
- **Alternatives Considered**: Selectively copying only `.conf` files was considered, but keeping the existing `cp -r data/bgmod/* ... && rm -f ...` pattern preserves consistency with the rest of the Makefile.

### Decision 3: Copy `bgmod-splash` to `AppDir/lib/` in `appimage/goverlay-appimage.sh`
- **Rationale**: In AppImage builds, `GetBGModBinariesSourceDir` in `bgmod_resources.pas` looks in `$APPDIR/lib`. Copying `bgmod-splash` alongside `bgmod` and `bgmod-uninstaller` ensures AppImage users have the binary available.

## Risks / Trade-offs

- [Risk] Package managers with different `libexecdir` conventions → Mitigation: Both `Makefile` and packaging scripts standardize on `prefix=/usr libexecdir=/lib` for Linux packaging consistency.
