## MODIFIED Requirements

### Requirement: Automated Flatpak Nightly Build
The system MUST build a Flatpak bundle (`.flatpak`) for both x86_64 and aarch64 architectures on every push to the main branch.

#### Scenario: Build Flatpak artifact
- **WHEN** a push occurs on the main branch
- **THEN** the CI workflow executes Flatpak build steps and produces `.flatpak` bundles for both x86_64 and aarch64 architectures.

### Requirement: Automated Debian Nightly Build
The system MUST build a Debian binary package (`.deb`) for both x86_64 and aarch64 architectures on every push to the main branch.

#### Scenario: Build Debian package
- **WHEN** a push occurs on the main branch
- **THEN** the CI workflow compiles and packages GOverlay into `.deb` archives for both x86_64 and aarch64 architectures.

### Requirement: Automated RPM Nightly Build
The system MUST build a Fedora-compatible RPM binary package (`.rpm`) for both x86_64 and aarch64 architectures on every push to the main branch.

#### Scenario: Build RPM package
- **WHEN** a push occurs on the main branch
- **THEN** the CI workflow compiles and packages GOverlay into `.rpm` archives for both x86_64 and aarch64 architectures.

### Requirement: Nightly Release Asset Enrichment
The system MUST upload the generated Flatpak, deb, and RPM packages for both x86_64 and aarch64 architectures as release assets to the GitHub nightly pre-release.

#### Scenario: Upload nightly package assets
- **WHEN** all nightly package formats (AppImage, Flatpak, deb, RPM) for both architectures are successfully built
- **THEN** the CI release step uploads these assets to the "nightly" release tag.
