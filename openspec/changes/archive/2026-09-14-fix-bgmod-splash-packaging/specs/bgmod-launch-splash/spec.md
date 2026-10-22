## ADDED Requirements

### Requirement: Distribution packaging and bundling of launch splash binary
The system packaging targets (including RPM specifications and AppImage bundling scripts) SHALL include the `bgmod-splash` binary in the expected library directory (`libexecdir` / `AppDir/lib`) and SHALL NOT leave unpackaged or misplaced ELF binaries in data directories.

#### Scenario: RPM package file list coverage
- **WHEN** the Goverlay RPM package is built via `rpmbuild`
- **THEN** `%{_prefix}/lib/bgmod-splash` is packaged in `%files`, satisfying the buildroot unpackaged file check without error.

#### Scenario: Removal of duplicate binary from data directory
- **WHEN** `make install` is executed
- **THEN** the `bgmod-splash` binary is pruned from `$(datadir)/goverlay/bgmod/`, preventing duplicate ELF binaries under `/usr/share`.

#### Scenario: AppImage bundling of launch splash
- **WHEN** the Goverlay AppImage is assembled via `goverlay-appimage.sh`
- **THEN** `bgmod-splash` is copied into `./AppDir/lib/bgmod-splash`, enabling runtime extraction and execution inside AppImage environments.
