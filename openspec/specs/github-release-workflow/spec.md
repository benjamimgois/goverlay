# GitHub Release Workflow

## Purpose
Build stable packages (AppImage, Flatpak, DEB, RPM), rename them based on version, and auto-create a GitHub Release with those packages on tag push.

## Requirements

### Requirement: Build stable packages on tag push
The workflow MUST build the AppImage (x86_64), Flatpak packages (x86_64, aarch64), and DEB/RPM packages (x86_64) when a tag matching `v*` or `[0-9]*` is created and pushed.

#### Scenario: Tag push triggers builds
- **WHEN** a new tag matching `v*` or `[0-9]*` is pushed to GitHub
- **THEN** the workflow builds the stable AppImage, DEB, and RPM packages for x86_64, and stable Flatpak packages for x86_64 and aarch64.

### Requirement: Package renaming based on version
The built release packages MUST be renamed according to the release version (tag name with leading 'v' removed, and dots replaced with underscores).

#### Scenario: Formatted version names
- **WHEN** a tag `v1.8.4` is pushed and packages are built
- **THEN** the built packages are renamed to `goverlay_1_8_4_x8664.appimage`, `goverlay_1_8_4_x8664.flatpak`, `goverlay_1_8_4_aarch64.flatpak`, `goverlay_1_8_4_x8664.deb`, and `goverlay_1_8_4_x8664.rpm`.

### Requirement: Auto-generated release creation
The workflow MUST create a GitHub Release for the tag and upload the renamed packages. The release notes MUST contain an auto-generated changelog in English.

#### Scenario: Release creation and asset upload
- **WHEN** the build and renaming steps finish successfully
- **THEN** the workflow creates a stable GitHub release with the tag name, generates release notes, and uploads the three renamed packages.
