## ADDED Requirements

### Requirement: E2E Headless GUI Test Execution
The GOverlay test suite SHALL support headless execution on Linux systems by spawning GOverlay inside a virtual X server (`Xvfb`).

#### Scenario: Running test runner inside Xvfb
- **WHEN** the test script is executed on a headless system
- **THEN** it launches an Xvfb virtual frame buffer, sets the `DISPLAY` environment variable, and boots the GOverlay binary successfully.

### Requirement: Automated UI Navigation and Configuration Assertion
The test runner SHALL be capable of navigating tabs (MangoHud, vkBasalt, OptiScaler) and asserting the correct mutation of config files upon clicking Save.

#### Scenario: Toggling GPU driver saves OptiScaler INI
- **WHEN** the test runner clicks the "OptiScaler" tab and switches the driver from MESA to NVIDIA
- **THEN** GOverlay silently saves `OptiScaler.ini` with `ForceReflex=false` and `SpoofDLSS=false`.

#### Scenario: Main save button writes config files
- **WHEN** the test runner edits settings on a tab and clicks the "Save" button
- **THEN** GOverlay writes the final configuration files, and a desktop notification/console output is captured.
