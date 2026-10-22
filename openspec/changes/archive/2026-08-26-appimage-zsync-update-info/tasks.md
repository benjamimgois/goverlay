## 1. AppImage Build Script Updates

- [x] 1.1 Update `appimage/goverlay-appimage.sh` to construct `UPINFO` with standard tags (`latest` / `nightly`) and set `OUTNAME` directly to `goverlay-${VERSION}-${ARCH}.AppImage`
- [x] 1.2 Verify `appimage/goverlay-appimage.sh` syntax and environment variable resolution

## 2. GitHub Actions Workflow Updates

- [x] 2.1 Update `.github/workflows/release.yml` to preserve, move, and publish `*.AppImage*` (including `.zsync` files) as release assets
- [x] 2.2 Update `.github/workflows/appimage.yml` to ensure nightly `.zsync` files are packaged and published
- [x] 2.3 Verify workflow YAML syntax with yamllint or schema validation
