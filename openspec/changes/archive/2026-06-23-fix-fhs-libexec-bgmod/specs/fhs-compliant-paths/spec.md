## ADDED Requirements

### Requirement: Architecture-dependent binary installation
The system installation SHALL place compiled architecture-dependent executables (`bgmod` and `bgmod-uninstaller`) in the `libexec` directory (e.g. `/usr/libexec/goverlay/` in production) rather than the shared data directory (e.g. `/usr/share/goverlay/bgmod/`).

#### Scenario: Installation check
- **WHEN** GOverlay is installed in the system via Makefile
- **THEN** `bgmod` and `bgmod-uninstaller` exist in the `libexec` folder, and the `/usr/share/goverlay/bgmod/` folder contains only architecture-independent data files.

### Requirement: Executable path resolution for bgmod
When GOverlay initializes or updates the user's local `bgmod` directory (`~/.local/share/goverlay/bgmod/`), it SHALL copy the `bgmod` and `bgmod-uninstaller` binaries from the folder where the `goverlay` executable resides.

#### Scenario: User folder initialization
- **WHEN** GOverlay launches and checks/initializes the user's `bgmod` directory
- **THEN** it copies `bgmod` and `bgmod-uninstaller` from GOverlay's binary directory to the user's local `bgmod` directory.
