## Why

Currently, GOverlay has workflows to build and release "nightly" versions of the AppImage and Flatpak packages, but does not automate stable releases on GitHub when a new tag is pushed. Users must manually create releases, write changelogs, and upload compiled binaries. Automated releases on tag push will save developer effort, ensure immediate availability of stable releases, and maintain consistent package versions.

## What Changes

- Add a new GitHub Action workflow (`.github/workflows/release.yml`) triggered when a new tag matching `v*` or `[0-9]*` is created.
- The workflow will build:
  - AppImage (x86_64)
  - Flatpak bundle (x86_64)
  - Flatpak bundle (aarch64)
- Rename the output packages according to the version:
  - `goverlay_<version_with_underscores>_x8664.appimage`
  - `goverlay_<version_with_underscores>_x8664.flatpak`
  - `goverlay_<version_with_underscores>_aarch64.flatpak`
  - `goverlay_<version_with_underscores>_x8664.deb`
  - `goverlay_<version_with_underscores>_x8664.rpm`
- Automatically generate a GitHub Release containing:
  - Auto-generated summarized changelog of the changes (in English).
  - The renamed release packages.

## Capabilities

### New Capabilities
- `github-release-workflow`: Automates stable releases on GitHub upon tag push with properly formatted package names and changelogs.

### Modified Capabilities

## Impact

- Untracked files added: `.github/workflows/release.yml`.
- No modifications to other codebase source files.
