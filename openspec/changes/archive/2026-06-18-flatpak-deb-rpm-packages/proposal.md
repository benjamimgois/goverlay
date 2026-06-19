## Why

Currently, GOverlay's nightly builds only package and release the application as an AppImage. Adding Flatpak, Debian (.deb), and Red Hat (.rpm) packages for Fedora will broaden distribution support, allowing users on diverse Linux distributions to install and update development builds easily via native package managers or flatpak.

## What Changes

- Automate Flatpak bundle generation (`.flatpak`) within the CI pipeline.
- Build Debian binary packages (`.deb`) for Debian/Ubuntu distributions.
- Build RPM binary packages (`.rpm`) tailored for Fedora/RHEL distributions.
- Integrate the publishing of these new package formats into the nightly pre-release workflow alongside the existing AppImage.

## Capabilities

### New Capabilities
- `nightly-multi-format-packages`: Automated packaging and nightly distribution of GOverlay as Flatpak, Debian (.deb), and RPM (.rpm) formats.

### Modified Capabilities
<!-- None -->

## Impact

- **CI/CD Workflows**: Changes to `.github/workflows/appimage.yml` (or creation of a unified nightly build workflow) to trigger flatpak, deb, and rpm builds.
- **Packaging Templates**: Addition of debian packaging files (e.g. control, rules) and RPM spec files or automated package builders (like `nfpm` or `fpm` or dedicated tools).
- **No pascal code changes** are expected, only build configuration.
