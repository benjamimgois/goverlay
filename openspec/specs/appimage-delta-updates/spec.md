# appimage-delta-updates Specification

## Purpose
Enables delta updates for GOverlay AppImage distributions by embedding standardized update information and publishing matching `.zsync` control files.

## Requirements

### Requirement: Embedded AppImage update information
The AppImage build script SHALL embed standardized update information (`UPINFO`) into the AppImage binary corresponding to the build target (stable release vs nightly build).

#### Scenario: Stable release AppImage build
- **WHEN** the AppImage is built for a release tag (e.g. `v1.9.0` with `TAG_NAME` defined)
- **THEN** `UPINFO` is set to `gh-releases-zsync|<owner>|<repo>|latest|goverlay-*-<arch>.AppImage.zsync` and the AppImage is generated with the output name `goverlay-<version>-<arch>.AppImage`.

#### Scenario: Nightly or continuous AppImage build
- **WHEN** the AppImage is built without a release tag (e.g. `nightly` or CI workflow)
- **THEN** `UPINFO` is set to `gh-releases-zsync|<owner>|<repo>|nightly|goverlay-*-<arch>.AppImage.zsync` and the AppImage is generated with the output name `goverlay-<version>-<arch>.AppImage`.

### Requirement: Publication of zsync control files in GitHub Releases
The GitHub Actions release pipelines SHALL upload the generated `.zsync` control files alongside the corresponding `.AppImage` files to GitHub Releases.

#### Scenario: Stable release workflow artifact upload
- **WHEN** a release tag is pushed and the stable release workflow executes
- **THEN** both `goverlay-<version>-<arch>.AppImage` and `goverlay-<version>-<arch>.AppImage.zsync` are collected into the distribution directory and published as assets in the GitHub Release.

#### Scenario: Nightly workflow artifact upload
- **WHEN** the nightly workflow runs on the `main` branch
- **THEN** both the nightly `.AppImage` and its matching `.AppImage.zsync` file are published as assets in the nightly pre-release.
