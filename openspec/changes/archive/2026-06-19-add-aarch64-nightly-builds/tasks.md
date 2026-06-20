## 1. Packaging Scripts Modification

- [x] 1.1 Update `packaging/deb/build-deb.sh` to dynamically resolve and substitute target Debian architecture in `control` file and the output package filename instead of hardcoding `amd64`.

## 2. GitHub Actions Nightly CI/CD Updates

- [x] 2.1 Update the `build` job in `.github/workflows/appimage.yml` to utilize a matrix strategy targeting both `x86_64` (`ubuntu-latest`) and `aarch64` (`ubuntu-24.04-arm`).
- [x] 2.2 Update the `build-flatpak` job in `.github/workflows/appimage.yml` to utilize a matrix strategy targeting both `x86_64` (`ubuntu-latest`) and `aarch64` (`ubuntu-24.04-arm`), renaming the output Flatpak bundle and upload artifact names accordingly.
- [x] 2.3 Update the `release_nightly` job in `.github/workflows/appimage.yml` to download and release artifacts for both `x86_64` and `aarch64` architectures.

## 3. Verification

- [x] 3.1 Verify the workflow configuration syntax and that `build-deb.sh` executes correctly.
