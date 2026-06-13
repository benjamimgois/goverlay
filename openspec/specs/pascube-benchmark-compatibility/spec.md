# Specification: pascube-benchmark-compatibility

## Purpose

Define compatibility requirements for the PasCube Vulkan-based benchmark, ensuring reliable operation across different Linux distributions (including Ubuntu, Bazzite, NixOS) and container environments (Flatpak).

## Requirements

### Requirement: Save and Load Benchmark Results from User Writeable Config Directory
The system MUST save and load the benchmark history to and from the user's config directory (fallback to `/tmp` if `HOME` is empty), ensuring compatibility with read-only installations (AppImage, Flatpak, NixOS read-only store, and system `/usr/` paths).

#### Scenario: Saving results
- **WHEN** the benchmark finishes execution
- **THEN** the system saves `benchmark_results.json` into the writeable config folder.

#### Scenario: Loading results
- **WHEN** the benchmark screen initializes
- **THEN** the system loads the history from `benchmark_results.json` in the writeable config folder.

### Requirement: Query Host OS Name inside Flatpak Sandbox
When executing inside Flatpak, the system MUST retrieve the host OS name by reading `/run/host/etc/os-release` or `/run/host/usr/lib/os-release`.

#### Scenario: Distro detection in flatpak
- **WHEN** queried for OS Name inside Flatpak
- **THEN** the system parses the host OS PRETTY_NAME from the host files.

### Requirement: Safe fallback for config paths
The system MUST NOT hardcode user home paths as default fallbacks when finding directories, utilizing `/tmp` instead.

#### Scenario: Empty HOME environment
- **WHEN** resolving the config directory path and `HOME` environment variable is not defined
- **THEN** the system defaults to `/tmp`.

### Requirement: Fallback validation for 7-Zip commands
The system MUST verify if `7z`, `7zz`, or `7za` is available on the system during CPU benchmarking.

#### Scenario: Spawning compression benchmark
- **WHEN** spawning the CPU benchmark
- **THEN** the system attempts to execute `7z`, falling back to `7zz` and then `7za` depending on system availability.
