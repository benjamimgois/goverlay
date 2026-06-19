## 1. Setup & Packaging Templates

- [x] 1.1 Create the Debian packaging metadata structure (e.g. control, rules, desktop and icon installation scripts) in a new `packaging/deb/` directory.
- [x] 1.2 Create the Fedora RPM Spec file (e.g. `goverlay.spec`) or package script in a new `packaging/rpm/` directory.

## 2. CI/CD Integration

- [x] 2.1 Modify `.github/workflows/appimage.yml` to add a Flatpak bundle build job using the existing flatpak manifest in `flatpak/`.
- [x] 2.2 Add jobs to the CI workflow to package the compiled GOverlay executable into `.deb` and `.rpm` files.
- [x] 2.3 Update the nightly pre-release deployment step to collect and upload `.flatpak`, `.deb`, and `.rpm` assets alongside the existing `.AppImage` file.

## 3. Verification

- [ ] 3.1 Trigger the CI workflow on a test branch to verify that all package formats build successfully.
- [ ] 3.2 Verify that all four formats (.AppImage, .flatpak, .deb, .rpm) are successfully uploaded to the nightly release assets on GitHub.
