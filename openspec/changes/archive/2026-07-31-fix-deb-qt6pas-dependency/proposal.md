## Why

The current GOverlay DEB package requires `libqt6pas6 (>= 6.2.0)`. However, Debian and Ubuntu/Kubuntu official repositories package `libqt6pas6` under package versioning `2.3.x` (even though the package contains `libQt6Pas.so.6.2.10`). As a result, APT compares package version numbers (`2.3 < 6.2.0`) and refuses to install GOverlay on Kubuntu/Ubuntu 24.04+ and 26.04.

## What Changes

- Remove the strict minimum version constraint `(>= 6.2.0)` from `libqt6pas6` dependency in `packaging/deb/control`.
- Update `packaging/deb/build-deb.sh` sed substitution rule to match the unconstrained `libqt6pas6` dependency string.

## Capabilities

### New Capabilities

### Modified Capabilities
- `nightly-multi-format-packages`: Ensure Debian `.deb` package dependency definitions are compatible with official Ubuntu/Debian distribution package versioning schemes.

## Impact

- `packaging/deb/control`: Modifies `Depends:` line.
- `packaging/deb/build-deb.sh`: Modifies sed regex for architecture-specific substitution.
- Fixes DEB package installation on Kubuntu, Ubuntu, Debian, and derivative distributions without dependency resolution errors.
