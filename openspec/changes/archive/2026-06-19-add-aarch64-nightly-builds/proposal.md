## Why

Currently, GOverlay nightly builds only generate and publish packages (AppImage, DEB, RPM, Flatpak) for the `x86_64` (amd64) architecture. To support ARM64 users (e.g., Raspberry Pi, Asahi Linux, ARM-based Chromebooks, etc.), we want to also produce and distribute `aarch64` (arm64) packages automatically as part of the nightly CI/CD release process.

## What Changes

- Update GitHub Actions workflow (`appimage.yml`) to build packages (AppImage, DEB, RPM, Flatpak) for both `x86_64` and `aarch64` architectures.
- Make Debian packaging scripts (`build-deb.sh` and control template) architecture-aware to correctly generate `arm64` packages on ARM64 hosts.
- Configure Flatpak nightly builds to run on native ARM64 runners (`ubuntu-24.04-arm`) using a matrix strategy.
- Update release job to download and upload both `x86_64` and `aarch64` package formats to the nightly pre-release.

## Capabilities

### New Capabilities

*(None)*

### Modified Capabilities

- `nightly-multi-format-packages`: Expand requirements to build and release packages for both `x86_64` and `aarch64` architectures.

## Impact

- **CI/CD Build Time**: Introduction of native ARM64 runners (`ubuntu-24.04-arm`) will increase total runner usage, but builds will run concurrently.
- **Workflow configuration**: Modifies `.github/workflows/appimage.yml`.
- **Packaging scripts**: Modifies `packaging/deb/build-deb.sh` to dynamically resolve architecture.
