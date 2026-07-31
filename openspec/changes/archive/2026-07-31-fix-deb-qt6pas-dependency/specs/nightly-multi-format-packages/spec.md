## MODIFIED Requirements

### Requirement: Automated Debian Nightly Build
The system MUST build a Debian binary package (`.deb`) for both x86_64 and aarch64 architectures on every push to the main branch, with package dependency specifications compatible with official Debian and Ubuntu/Kubuntu package versioning schemes.

#### Scenario: Build Debian package
- **WHEN** a push occurs on the main branch
- **THEN** the CI workflow compiles and packages GOverlay into `.deb` archives for both x86_64 and aarch64 architectures without specifying incompatible minimum version constraints for distro-provided libraries such as `libqt6pas6`.
