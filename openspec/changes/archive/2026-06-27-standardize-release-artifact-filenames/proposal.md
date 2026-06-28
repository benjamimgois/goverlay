## Why

Release asset filenames currently use underscores as section separators and omit dots in version numbers (`goverlay_1_8_4_x8664.appimage`). This causes automated package managers like GearLever to fail wildcard matching and version detection due to ambiguous token delimiters. Standardizing release artifact filenames to hyphens and semantic versioning (`goverlay-1.8.4-x86_64.AppImage`) resolves compatibility issues with downstream Linux package managers.

## What Changes

- Standardize release artifact filename format across all published packages in GitHub Releases workflow.
- Replace section delimiters `_` with hyphens `-` in release asset names (`goverlay-<version>-<arch>.<ext>`).
- Preserve dot notation in version strings (`1.8.4` instead of `1_8_4`).
- Standardize architecture naming (`x86_64` instead of `x8664`, `aarch64` for ARM64).
- Use standard `.AppImage` extension capitalization for AppImage builds.

## Capabilities

### New Capabilities

- `release-artifact-naming`: Defines standard naming conventions for published release packages across formats (`.AppImage`, `.deb`, `.rpm`, `.flatpak`).

### Modified Capabilities

(none)

## Impact

- `.github/workflows/release.yml`: Artifact renaming step updated to produce standard filenames upon tag releases.
- No impact on internal application code or GOverlay update checking logic.
