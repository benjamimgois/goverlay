## Context

GOverlay needs stable releases created automatically whenever a new tag is pushed. Currently, `flatpak-release.yml` compiles Flatpak bundles but doesn't create releases, and `appimage.yml` only releases nightly versions. We need a unified release workflow that handles stable AppImage and Flatpak builds for both architectures on tag push, renames the output assets according to the tag name (with underscores and normalized suffixes), generates a changelog, and uploads the packages.

## Goals / Non-Goals

**Goals:**
- Automatically trigger on tag creation (`v*` or `[0-9]*`).
- Compile stable AppImage (x86_64) using the existing build steps.
- Compile stable Flatpak bundles for `x86_64` (amd64) and `aarch64` (arm64) using the stable flatpak manifest `flatpak/io.github.benjamimgois.goverlay.yml`.
- Compile stable DEB and RPM packages (x86_64) using the existing packaging scripts.
- Rename the output packages according to the user's requested naming convention:
  - `goverlay_<version_with_underscores>_x8664.appimage`
  - `goverlay_<version_with_underscores>_x8664.flatpak`
  - `goverlay_<version_with_underscores>_aarch64.flatpak`
  - `goverlay_<version_with_underscores>_x8664.deb`
  - `goverlay_<version_with_underscores>_x8664.rpm`
- Automate GitHub Release creation with English changelogs and stable assets.

**Non-Goals:**
- Modifying the existing nightly workflow (`appimage.yml`).

## Decisions

### 1. Unified release workflow triggering on tag push
- **Choice**: Create a new workflow `.github/workflows/release.yml` triggered on tag pushes (`v*` and `[0-9]*`).
- **Rationale**: Keeps release automation separate from daily CI/CD (which triggers on branch pushes).

### 2. Arch mapping and package renaming in workflow steps
- **Choice**: Rename the compiled assets in the workflow script steps using standard bash parameter expansion:
  ```bash
  TAG_NAME="${{ github.ref_name }}"
  CLEAN_VERSION="${TAG_NAME#v}"
  VERSION_UNDERSCORE="${CLEAN_VERSION//./_}"
  # For AppImage
  mv GOverlay-*.AppImage goverlay_${VERSION_UNDERSCORE}_x8664.appimage
  # For Flatpak x86_64
  mv goverlay-*.flatpak goverlay_${VERSION_UNDERSCORE}_x8664.flatpak
  # For Flatpak aarch64
  mv goverlay-*.flatpak goverlay_${VERSION_UNDERSCORE}_aarch64.flatpak
  # For DEB
  mv *.deb goverlay_${VERSION_UNDERSCORE}_x8664.deb
  # For RPM
  mv *.rpm goverlay_${VERSION_UNDERSCORE}_x8664.rpm
  ```
- **Rationale**: Simple, zero-dependency, and works reliably across the build steps.

### 3. Use `softprops/action-gh-release` for releases
- **Choice**: Reuse `softprops/action-gh-release@v2` with `generate_release_notes: true` to generate the English changelog and upload the assets.
- **Rationale**: Standard, well-supported action that integrates natively with GitHub's auto-generated release notes.

## Risks / Trade-offs

- **[Risk]** The ARM flatpak builder job requires ARM runner (`ubuntu-24.04-arm`), which might not be available on all GitHub organizations or accounts.
  - *Mitigation*: We will use the same runner configuration as `flatpak-release.yml` (`ubuntu-24.04-arm`), which is already supported and used in GOverlay.
