## Context

Currently, GOverlay publishes its nightly builds to the "nightly" pre-release tag, but only in the AppImage format (built via `.github/workflows/appimage.yml`). While a Flatpak workflow exists in `.github/workflows/flatpak-release.yml`, it is currently manual (via `workflow_dispatch`) and not part of the nightly release process. There are no automated workflows or configurations to generate Debian (`.deb`) or Fedora (`.rpm`) packages.

## Goals / Non-Goals

**Goals:**
- Automate building of Flatpak bundles, Debian packages, and Fedora RPM packages for the x86_64 architecture on every push to the `main` branch.
- Publish all three new formats (`.flatpak`, `.deb`, `.rpm`) to the GitHub `nightly` release tag alongside the existing AppImage.

**Non-Goals:**
- Submitting nightly builds to official upstream repositories (e.g., Flathub, Debian/Ubuntu archives, or Fedora updates).
- Support for non-x86_64 architectures (e.g. ARM64) for nightly builds.

## Decisions

### 1. Unified Nightly Pipeline
- **Decision**: Integrate Flatpak, deb, and rpm builds directly into `.github/workflows/appimage.yml` (renaming or refactoring it as a unified nightly release workflow), or have them run in parallel and upload their artifacts for the final release job to collect and publish.
- **Rationale**: Keeps the nightly release logic in one place. Running builds in parallel jobs reduces total CI time.

### 2. Debian (.deb) Packaging
- **Decision**: Use a debian template directory containing `DEBIAN/control` and standard `dpkg-deb --build` commands.
- **Rationale**: Minimal external dependencies; `dpkg-deb` is standard and natively available. We will compile GOverlay using `make` and install it into a temporary root directory (`DESTDIR`) before packing.

### 3. RPM (.rpm) Packaging
- **Decision**: Use `rpmbuild` or `alien` (converting the built `.deb` to `.rpm`).
- **Rationale**: Converting the `.deb` using `alien` is fast and highly reliable for simple GUI tools like GOverlay, avoiding the need to write and maintain a separate `.spec` file. Alternatively, we can use a simple RPM spec file in a Fedora container. Let's decide to use a simple RPM spec file or `alien` based on what is easier to integrate in the Github Runner.

### 4. Flatpak Bundle (.flatpak) Packaging
- **Decision**: Reuse the flatpak build configuration in the `flatpak/` directory, running `flatpak-builder` and `flatpak build-bundle` as part of the nightly CI.
- **Rationale**: Leverages existing, working Flatpak manifest and build scripts.

## Risks / Trade-offs

- **CI Build Time**
  - *Risk*: Flatpak builds require installing runtimes/SDKs and compiling the application, which can increase CI run time significantly.
  - *Mitigation*: Run Flatpak, deb/rpm, and AppImage builds in parallel runner jobs, using `actions/upload-artifact` and `actions/download-artifact` to compile them separately and package them in a single nightly release job.
