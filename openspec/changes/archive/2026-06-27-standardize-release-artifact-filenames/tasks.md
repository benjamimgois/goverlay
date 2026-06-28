## 1. Release Workflow Configuration

- [x] 1.1 Update `.github/workflows/release.yml` stable packages rename step to use `goverlay-${CLEAN_VERSION}-x86_64.AppImage`, `.deb`, and `.rpm`.
- [x] 1.2 Update `.github/workflows/release.yml` Flatpak bundle rename step to use `goverlay-${CLEAN_VERSION}-x86_64.flatpak` and `goverlay-${CLEAN_VERSION}-aarch64.flatpak`.
- [x] 1.3 Verify release upload patterns in `release.yml` match new filename extensions and naming scheme.
