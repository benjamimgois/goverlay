## Purpose
Define the requirements for automated end-to-end (E2E) integration testing of the GOverlay GUI interface.
## Requirements
### Requirement: E2E Headless GUI Test Execution
The GOverlay test suite SHALL support headless execution on Linux systems by spawning GOverlay inside a virtual X server (`Xvfb`).

To prevent interactive changelog modal popups from blocking inputs on fresh startup, the test runner SHALL seed a mock initial GOverlay configuration setting `ChangelogSeenVersion` to the current application version.

#### Scenario: Running test runner inside Xvfb
- **WHEN** the test script is executed on a headless system
- **THEN** it seeds a mock config file, launches an Xvfb virtual frame buffer, sets the `DISPLAY` environment variable, and boots the GOverlay binary successfully without spawning modal popups.

### Requirement: Automated UI Navigation and Configuration Assertion
The test runner SHALL be capable of navigating tabs (MangoHud, vkBasalt, OptiScaler) and asserting the correct mutation of config files upon clicking Save.

To handle fractional screen scaling, window resizing, and custom title bar decorations on host displays, the test runner SHALL calculate click coordinates dynamically: using absolute values for fixed-width sidebar elements (width=211), left-relative values for left-anchored components, right-relative coordinates for right-anchored components, and employ a sweep-based click search on critical settings until a successful configuration file update is observed.

#### Scenario: Toggling GPU driver saves OptiScaler INI
- **WHEN** the test runner clicks the "OptiScaler" tab and switches the driver from MESA to NVIDIA using LCL-anchoring-aware scaled coordinates and a vertical sweep of mouse click positions
- **THEN** GOverlay silently saves `OptiScaler.ini` with `ForceReflex=false` and `SpoofDLSS=false`.

#### Scenario: Main save button writes config files
- **WHEN** the test runner edits settings on a tab and clicks the "Save" button using DPI-scaled coordinates
- **THEN** GOverlay writes the final configuration files, and a desktop notification/console output is captured.

### Requirement: E2E Test Dependency Security
The E2E test runner environment SHALL utilize non-vulnerable python dependency versions (specifically `pytest>=9.0.3` and `pillow>=12.2.0`) to avoid security alerts.

#### Scenario: Running test runner checks secure dependency versions
- **WHEN** the E2E test runner is executed or dependencies are audited
- **THEN** both `pytest` and `pillow` package versions satisfy the secure minimums (`pytest>=9.0.3` and `pillow>=12.2.0`)

