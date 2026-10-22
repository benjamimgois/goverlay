## Context

GOverlay Flatpak manifests (`io.github.benjamimgois.goverlay.yml` and `io.github.benjamimgois.goverlay.nightly.yml`) were updated to KDE 6.11 runtime. The CI workflows and `flatpak/build-flatpak.sh` still referenced 6.10, causing `flatpak-builder` to fail due to missing SDK dependencies.

## Goals / Non-Goals

**Goals:**
- Align all workflow installation steps with KDE 6.11 SDK and runtime.
- Align `flatpak/build-flatpak.sh` dependency checklist with KDE 6.11.

**Non-Goals:**
- Modifying Flatpak permissions or module declarations.

## Decisions

### Decision 1: Update SDK/Runtime version string across all workflows and scripts
- Replace `6.10` with `6.11` for `org.kde.Platform`, `org.kde.Sdk`, and `io.qt.qtwebengine.BaseApp` across:
  - `.github/workflows/appimage.yml`
  - `.github/workflows/release.yml`
  - `.github/workflows/flatpak-release.yml`
  - `flatpak/build-flatpak.sh`
- Rationale: Ensures `flatpak-builder` can successfully locate and initialize the build sandbox with the version specified in the manifest.

## Risks / Trade-offs

- **[Risk] Flathub availability**: Flathub must host the 6.11 runtimes for both x86_64 and aarch64.
  - **Mitigation**: Verified via `flatpak remote-ls flathub` that `org.kde.Platform//6.11`, `org.kde.Sdk//6.11`, and `io.qt.qtwebengine.BaseApp//6.11` are live on Flathub.
