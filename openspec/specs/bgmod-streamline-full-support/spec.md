## Purpose

Provides complete Streamline SDK deployment, backup, and restoration handling in bgmod, preventing ABI version mismatches and protecting native game files.

## Requirements

### Requirement: Full Streamline SDK deployment
The system SHALL deploy all available Streamline SDK DLLs from the source cache directory into the game directory during DLSS Enabler installation.

#### Scenario: Full suite of Streamline plugins deployed
- **WHEN** DLSS Enabler is installed or verified by `bgmod`
- **THEN** all available Streamline libraries (including `sl.common.dll`, `sl.interposer.dll`, `sl.dlss.dll`, `sl.dlss_g.dll`, `sl.reflex.dll`, `sl.nis.dll`, `sl.pcl.dll`, `sl.deepdvc.dll`, `sl.directsr.dll`, `sl.dlss_d.dll`, `sl.imgui.dll`, and `sl.nvperf.dll`) present in the source directory are copied into the game directory, preventing version fragmentation.

### Requirement: Streamline native binaries backup and restoration
The system SHALL treat all Streamline SDK DLLs as original game files when present in the game directory prior to modification, backing them up before replacement and restoring them upon uninstallation or cleanup.

#### Scenario: Original Streamline binaries backed up
- **WHEN** `bgmod` initializes in a game containing native Streamline DLLs
- **THEN** existing Streamline DLLs are safely copied to the `backups/` directory before any replacement files are written.

#### Scenario: Original Streamline binaries restored upon uninstallation
- **WHEN** OptiScaler or DLSS Enabler is disabled or uninstalled in `bgmod`
- **THEN** backed up native Streamline DLLs are restored to the game directory, and any non-native Streamline DLLs deployed by the mod are cleaned up.
