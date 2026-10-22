## Context

GOverlay builds AppImages using `quick-sharun` and `appimagetool` in `appimage/goverlay-appimage.sh`, which is orchestrated by GitHub Actions workflows (`.github/workflows/release.yml` and `.github/workflows/appimage.yml`).

## Goals / Non-Goals

**Goals:**
- Unify AppImage naming convention across build scripts and release workflows to `goverlay-${VERSION}-${ARCH}.AppImage`.
- Embed standardized `UPINFO` strings (`gh-releases-zsync|<owner>|<repo>|<tag>|<pattern>`).
- Preserve and publish `.zsync` files alongside AppImages on GitHub Releases.
- Ensure compatibility with tools implementing AppImageUpdate specification (AppImageLauncher, AppManager, AM, GearLever).

**Non-Goals:**
- Changing the underlying runtime packaging (`quick-sharun` / `uruntime`).
- Adding in-app self-updater UI within GOverlay itself.

## Decisions

### Decision 1: Generate AppImage directly with final naming
- In `appimage/goverlay-appimage.sh`, set `OUTNAME="goverlay-${VERSION}-${ARCH}.AppImage"`.
- Rationale: `appimagetool` writes the target AppImage name directly into the `Filename:` header of the generated `.zsync` file. Generating the file with the final name from the start eliminates the need to post-process or rename the AppImage and `.zsync` files in CI, preventing broken references.

### Decision 2: Context-aware `UPINFO` tag selection
- Determine the update channel tag dynamically:
  - When building a tagged release (`TAG_NAME` is set in environment): use `latest`.
  - When building a continuous/nightly run: use `nightly`.
- Use a safe fallback for `GITHUB_REPOSITORY` (`${GITHUB_REPOSITORY:-benjamimgois/goverlay}`) to extract owner and repo name cleanly without external piping.
- Use pattern `goverlay-*-${ARCH}.AppImage.zsync`.

### Decision 3: Update GitHub Actions workflows to upload `.zsync` files
- In `release.yml`:
  - Update `mv` command to move `goverlay-*-x86_64.AppImage*` into `./dist/`.
  - Update `files:` pattern in `softprops/action-gh-release` to include `*.AppImage*`.
- In `appimage.yml`:
  - Pass `TAG_NAME` if applicable, and ensure `*.AppImage*` uploads the `.zsync` file to the nightly release.

## Risks / Trade-offs

- **[Risk] GitHub API rate limits during updater checks**: `AppImageUpdate` tools query the public GitHub API to resolve the `latest` or `nightly` release tag.
  - **Mitigation**: Standard behavior for all GitHub-hosted AppImages; `gh-releases-zsync` uses unauthenticated GitHub API endpoints with caching handled by clients.
