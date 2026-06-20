## Context

Currently, the GOverlay nightly release CI/CD workflow in `.github/workflows/appimage.yml` is hardcoded to build, package, and publish only `x86_64` (amd64) artifacts. To support ARM64 users, we need to extend this pipeline to build `aarch64` (arm64) versions of all package formats (AppImage, DEB, RPM, Flatpak) using GitHub's native ARM64 runners.

## Goals / Non-Goals

**Goals:**
- Add `aarch64` build target to the nightly pipeline.
- Build AppImage, DEB, and RPM formats for `aarch64` inside a containerized Arch Linux environment.
- Build Flatpak package format for `aarch64` using `ubuntu-24.04-arm` runner.
- Update release steps to publish all four formats for both architectures (`x86_64` and `aarch64`).

**Non-Goals:**
- Support architectures other than `x86_64` and `aarch64` (e.g., `armv7` or `riscv64`).
- Modify the release Flatpak workflow (`flatpak-release.yml`), which already supports a matrix structure.

## Decisions

### 1. Matrix Strategy in `appimage.yml`
We will introduce a GitHub Actions matrix in the `build` and `build-flatpak` jobs.
- **x86_64**: Runs on `ubuntu-latest`.
- **aarch64**: Runs on `ubuntu-24.04-arm`.
- Rationale: Matrix strategy simplifies the pipeline and avoids duplicating step logic. Using native ARM64 runners (`ubuntu-24.04-arm`) ensures fast native build times compared to QEMU emulation.

### 2. Make `build-deb.sh` Architecture-Aware
The deb packaging script (`packaging/deb/build-deb.sh`) and control template currently hardcode `amd64` architecture.
- We will dynamically map `uname -m` output (e.g., `aarch64` -> `arm64`, `x86_64` -> `amd64`).
- We will use `sed` to replace the `Architecture: amd64` field in the generated control file with the resolved Debian architecture.
- We will name the output file using the resolved architecture: `goverlay_${VERSION}_${DEB_ARCH}.deb`.
- Rationale: This allows the same script to work seamlessly across different host architectures.

### 3. Separate Flatpak Artifact Names and Uploads
To prevent flatpak bundles from overwriting each other:
- The Flatpak build will output `goverlay-nightly-${{ matrix.arch }}.flatpak`.
- The upload step will use the artifact name `flatpak-bundle-${{ matrix.arch }}`.
- Rationale: Keeps x86_64 and aarch64 Flatpak bundles distinct.

## Risks / Trade-offs

- **Risk**: GitHub Actions native ARM64 runners might run out of concurrency limits or have longer queue times.
  - *Mitigation*: Public repositories get free and unlimited standard ARM64 runners.
- **Risk**: Dynamic substitution in `build-deb.sh` could fail if `uname -m` outputs unexpected values.
  - *Mitigation*: Fallback to using the raw `uname -m` output if it is not `x86_64` or `aarch64`.
