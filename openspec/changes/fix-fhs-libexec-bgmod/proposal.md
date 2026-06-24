## Why

Installing architecture-dependent ELF binaries (`bgmod` and `bgmod-uninstaller`) under `/usr/share` violates the Filesystem Hierarchy Standard (FHS). This causes packaging linters (like the RPM build linter on openSUSE and Fedora) to fail the build process due to arch-dependent files in `/usr/share`.

## What Changes

- Update `Makefile` to install `bgmod` and `bgmod-uninstaller` into `/usr/libexec/goverlay/` instead of `/usr/share/goverlay/bgmod/`.
- Update `Makefile` to remove `bgmod` and `bgmod-uninstaller` from `/usr/share/goverlay/bgmod/` after copying data files.
- Update `bgmod_resources.pas` to copy the `bgmod` and `bgmod-uninstaller` binaries from the GOverlay executable's directory (`/usr/libexec/goverlay/` in production) instead of `/usr/share/goverlay/bgmod/`.

## Capabilities

### New Capabilities

- `fhs-compliant-paths`: Ensure all architecture-dependent compiled binaries are installed under `/usr/libexec/goverlay/` and not in `/usr/share`.

### Modified Capabilities

*(None)*

## Impact

- `Makefile`: Change destination paths for compiled binaries during installation.
- `bgmod_resources.pas`: Adjust GOverlay initialization code to copy binaries from the binary directory and other assets from the shared data directory.
