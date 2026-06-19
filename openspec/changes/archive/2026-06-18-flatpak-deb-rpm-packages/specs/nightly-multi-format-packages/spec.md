## ADDED Requirements

### Requirement: Automated Flatpak Nightly Build
The system MUST build a Flatpak bundle (`.flatpak`) for x86_64 architecture on every push to the main branch.

#### Scenario: Build Flatpak artifact
- **WHEN** a push occurs on the main branch
- **THEN** the CI workflow executes Flatpak build steps and produces a `.flatpak` bundle.

### Requirement: Automated Debian Nightly Build
The system MUST build a Debian binary package (`.deb`) for x86_64 architecture on every push to the main branch.

#### Scenario: Build Debian package
- **WHEN** a push occurs on the main branch
- **THEN** the CI workflow compiles and packages GOverlay into a `.deb` archive.

### Requirement: Automated RPM Nightly Build
The system MUST build a Fedora-compatible RPM binary package (`.rpm`) for x86_64 architecture on every push to the main branch.

#### Scenario: Build RPM package
- **WHEN** a push occurs on the main branch
- **THEN** the CI workflow compiles and packages GOverlay into an `.rpm` archive.

### Requirement: Nightly Release Asset Enrichment
The system MUST upload the generated Flatpak, deb, and RPM packages as release assets to the GitHub nightly pre-release.

#### Scenario: Upload nightly package assets
- **WHEN** all nightly package formats (AppImage, Flatpak, deb, RPM) are successfully built
- **THEN** the CI release step uploads these assets to the "nightly" release tag.
