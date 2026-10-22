## Why

GOverlay AppImage users currently cannot perform fast delta updates via standard tools like AppImageUpdate, AppImageLauncher, AppManager, or GearLever because `.zsync` control files are not published with stable releases, and the embedded update information string uses a non-standard `latest-all` tag with mismatched file names (Issue #399).

## What Changes

- Update `appimage/goverlay-appimage.sh` to generate the AppImage directly with its standard output filename (`goverlay-${VERSION}-${ARCH}.AppImage`), ensuring the embedded `Filename:` header inside the generated `.zsync` control file matches the release asset.
- Format `UPINFO` with standard tags (`latest` for release builds with `TAG_NAME`, `nightly` for continuous builds) and safe fallback repository variables.
- Update `.github/workflows/release.yml` to preserve, move, and upload `*.AppImage*` (including `.zsync` files) as release assets on stable releases.
- Ensure `.github/workflows/appimage.yml` packages and publishes `.zsync` files for nightly releases.

## Capabilities

### New Capabilities
- `appimage-delta-updates`: Embedding standardized update information and publishing `.zsync` control files alongside AppImage packages for fast delta updates.

### Modified Capabilities
<!-- None -->

## Impact

- **Affected Files**: `appimage/goverlay-appimage.sh`, `.github/workflows/release.yml`, `.github/workflows/appimage.yml`
- **Affected Systems**: AppImage build pipeline and GitHub Releases packaging.
- **Breaking Changes**: None. Backwards-compatible; adds `.zsync` files to release assets without altering existing package functionality.
