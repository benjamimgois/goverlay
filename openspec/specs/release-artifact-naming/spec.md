## ADDED Requirements

### Requirement: Standard release artifact naming
The release workflow SHALL publish release build artifacts formatted as `<AppName>-<Version>-<Architecture>.<Extension>` using hyphens as section delimiters and semantic dots in version strings.

#### Scenario: AppImage package naming
- **WHEN** GitHub release workflow builds and packages the x86_64 AppImage for version 1.8.4
- **THEN** the published artifact is named `goverlay-1.8.4-x86_64.AppImage`

#### Scenario: Debian package naming
- **WHEN** GitHub release workflow packages the x86_64 Debian package for version 1.8.4
- **THEN** the published artifact is named `goverlay-1.8.4-x86_64.deb`

#### Scenario: RPM package naming
- **WHEN** GitHub release workflow packages the x86_64 RPM package for version 1.8.4
- **THEN** the published artifact is named `goverlay-1.8.4-x86_64.rpm`

#### Scenario: Flatpak bundle naming
- **WHEN** GitHub release workflow creates Flatpak bundles for version 1.8.4 on x86_64 and arm64 architectures
- **THEN** the published artifacts are named `goverlay-1.8.4-x86_64.flatpak` and `goverlay-1.8.4-aarch64.flatpak` respectively
