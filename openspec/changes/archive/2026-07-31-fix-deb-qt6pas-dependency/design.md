## Context

See proposal.md. Currently, `packaging/deb/control` specifies `libqt6pas6 (>= 6.2.0)`. However, Debian and Ubuntu (including Kubuntu 26.04) package `libqt6pas6` under package versioning `2.3.x`.

## Goals / Non-Goals

**Goals:**
- Update `packaging/deb/control` to require `libqt6pas6` without version restriction `(>= 6.2.0)`.
- Update `packaging/deb/build-deb.sh` sed substitution script to match `libqt6pas6` without version constraint.

**Non-Goals:**
- Changing RPM packaging dependencies (`goverlay.spec`).
- Changing Flatpak permissions or manifests.

## Decisions

### Decision 1: Remove version constraint from `libqt6pas6` in `control`
- **Choice**: Replace `libqt6pas6 (>= 6.2.0)` with `libqt6pas6`.
- **Rationale**: Any official package of `libqt6pas6` in Debian/Ubuntu contains `libQt6Pas.so.6.2.x`. Distro versioning uses `2.3.x`, so removing the version requirement allows APT to successfully resolve the dependency.
- **Alternatives Considered**:
  - `libqt6pas6 (>= 2.3)`: Works for current Debian/Ubuntu releases, but could break if third-party repos or backports use different lower versions. Removing version constraint is standard for distro dependencies where the library versioning is managed by the distro.

### Decision 2: Update `build-deb.sh` sed pattern
- **Choice**: Update `sed -e "s/libqt6pas6 (>= 6.2.0)/libqt5pas1/g"` to `sed -e "s/libqt6pas6/libqt5pas1/g"` (for aarch64 build substitution).
- **Rationale**: Keeps script aligned with the updated `control` file.

## Risks / Trade-offs

- [Risk] Installation on a system where an outdated `libqt6pas6` without Qt6Pas 6.2 symbols is installed (extremely unlikely in any supported distro).
  - Mitigation: `libqt6pas6` in Debian/Ubuntu official repos is already built against Qt6 / Qt6Pas 6.2+.
