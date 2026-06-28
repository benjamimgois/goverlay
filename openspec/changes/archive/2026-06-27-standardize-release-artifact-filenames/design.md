## Context

GOverlay produces multiple release artifacts on GitHub Releases (.AppImage, .deb, .rpm, .flatpak) via GitHub Actions (`.github/workflows/release.yml`). Currently, the renaming step transforms semantic versions into underscore-separated strings (e.g. `1_8_4`) and uses underscores to join all filename components (`goverlay_1_8_4_x8664.appimage`). This hinders third-party Linux package management tools (like GearLever and AppImagePool) from using glob patterns to detect updates.

## Goals / Non-Goals

**Goals:**
- Standardize release artifact asset names in `.github/workflows/release.yml`.
- Adopt standard pattern: `<AppName>-<Version>-<Architecture>.<Extension>` (e.g. `goverlay-1.8.4-x86_64.AppImage`).
- Ensure all package formats (.AppImage, .deb, .rpm, .flatpak) use consistent hyphen delimiters and semantic version strings.

**Non-Goals:**
- Modifying internal application code or GOverlay update check logic (which uses GitHub Tags API directly).
- Modifying Linux package internal metadata (control files, rpm specs, flatpak manifests).

## Decisions

### Decision 1: Use Hyphens as Section Delimiters and Preserve Version Dots
- **Choice**: Format filenames as `goverlay-${CLEAN_VERSION}-${ARCH}.${EXT}`.
- **Rationale**: Hyphens cleanly separate component names from version numbers and architecture specs without colliding with dots in semantic versions (`1.8.4`) or underscores in architecture identifiers (`x86_64`).
- **Alternatives Considered**: Keeping underscores for seps (`goverlay_1.8.4_x86_64.AppImage`) — discarded because hyphens are standard for AppImage and cross-distro package releases.

### Decision 2: Standardize Architecture and Extension Strings
- **Choice**: Use `x86_64` (instead of `x8664`), `aarch64` for ARM64, and `.AppImage` (uppercase A and I).
- **Rationale**: Align with standard Linux architecture naming and official AppImageSpec file extension guidelines.

## Risks / Trade-offs

- **[Risk] Downstream script breakages** → Users running custom hardcoded curl/wget scripts targeting exact legacy filenames (`goverlay_*_x8664.appimage`) will need to update to wildcard or new standard patterns.
  - *Mitigation*: The change will coincide with a new release tag.
