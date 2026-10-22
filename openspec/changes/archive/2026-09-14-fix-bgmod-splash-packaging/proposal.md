## Why

The GitHub Actions package release workflow failed during the RPM packaging step (`rpmbuild`) with `error: Installed (but unpackaged) file(s) found: /usr/lib/bgmod-splash`. When `bgmod-splash` was introduced to `Makefile`'s install target, it was not added to the `%files` manifest in `packaging/rpm/goverlay.spec`, triggering `rpmbuild`'s strict unpackaged file check. Furthermore, `Makefile` failed to prune the binary from `$(datadir)/goverlay/bgmod/`, creating an unintended duplicate ELF binary in `/usr/share`, and `appimage/goverlay-appimage.sh` omitted copying `bgmod-splash` into `AppDir/lib/`.

## What Changes

- Add `%{_prefix}/lib/bgmod-splash` to the `%files` list in `packaging/rpm/goverlay.spec`.
- Prune `$(DESTDIR)$(prefix)$(datadir)/goverlay/bgmod/bgmod-splash` in `Makefile`'s `install` target so that architecture-dependent ELF binaries are not placed under `datadir`.
- Copy `bgmod-splash` into `./AppDir/lib/bgmod-splash` in `appimage/goverlay-appimage.sh` so AppImage distributions bundle the splash binary for user-space deployment.

## Capabilities

### New Capabilities
None.

### Modified Capabilities
- `bgmod-launch-splash`: Packaging and distribution manifests include `bgmod-splash` alongside existing `bgmod` components without lingering unpackaged binaries or duplicate data files.

## Impact

- `packaging/rpm/goverlay.spec`: Resolves RPM build failure in CI.
- `Makefile`: Cleans up `/usr/share` installation tree.
- `appimage/goverlay-appimage.sh`: Ensures `bgmod-splash` is bundled inside AppImage releases.
