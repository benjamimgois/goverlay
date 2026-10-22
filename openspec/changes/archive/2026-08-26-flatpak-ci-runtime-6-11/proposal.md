## Why

Flatpak bundle builds in GitHub Actions workflows fail because the Flatpak manifests (`io.github.benjamimgois.goverlay.yml` and `io.github.benjamimgois.goverlay.nightly.yml`) require KDE Platform and SDK version `6.11`, whereas the CI workflows and build script install version `6.10`.

## What Changes

- Update `.github/workflows/appimage.yml` to install `org.kde.Platform//6.11`, `org.kde.Sdk//6.11`, and `io.qt.qtwebengine.BaseApp//6.11`.
- Update `.github/workflows/release.yml` to install `org.kde.Platform//6.11`, `org.kde.Sdk//6.11`, and `io.qt.qtwebengine.BaseApp//6.11`.
- Update `.github/workflows/flatpak-release.yml` to install `org.kde.Platform//6.11`, `org.kde.Sdk//6.11`, and `io.qt.qtwebengine.BaseApp//6.11`.
- Update `flatpak/build-flatpak.sh` to require and install version `6.11` of the KDE Platform, SDK, and QtWebEngine BaseApp runtimes.

## Capabilities

### New Capabilities
- `flatpak-runtime-alignment`: Alignment of Flatpak build pipelines and local scripts with KDE Platform / SDK 6.11.

### Modified Capabilities
<!-- None -->

## Impact

- **Affected Files**: `.github/workflows/appimage.yml`, `.github/workflows/release.yml`, `.github/workflows/flatpak-release.yml`, `flatpak/build-flatpak.sh`
- **Affected Systems**: GitHub Actions CI Flatpak jobs and local Flatpak build scripts.
- **Breaking Changes**: None.
