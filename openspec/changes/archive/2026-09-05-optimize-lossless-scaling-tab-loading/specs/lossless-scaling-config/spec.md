## ADDED Requirements

### Requirement: Non-blocking software status detection and instantaneous tab switching
The system SHALL detect installed software status without executing blocking external shell commands on the GUI thread, parsing the Vulkan layer JSON directly for layer versions and caching results to ensure instantaneous tab display.

#### Scenario: Switching to Lossless Scaling tab
- **WHEN** user navigates to the Lossless Scaling tab
- **THEN** the tab contents render immediately without UI freeze, reading layer metadata directly from disk and avoiding blocking package manager queries.

#### Scenario: On-demand Steam DLL lookup
- **WHEN** the active configuration or profile already contains a configured Lossless.dll path
- **THEN** the system uses the configured path directly and skips full Steam library scans.
