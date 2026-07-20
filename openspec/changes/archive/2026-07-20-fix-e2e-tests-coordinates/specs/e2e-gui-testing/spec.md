## MODIFIED Requirements

### Requirement: Automated UI Navigation and Configuration Assertion
The test runner SHALL be capable of navigating tabs (MangoHud, vkBasalt, OptiScaler) and asserting the correct mutation of config files upon clicking Save.

To handle fractional screen scaling and custom title bar decorations on host displays, the test runner SHALL scale coordinates dynamically relative to the window geometry and employ a sweep-based click search on critical settings until a successful configuration file update is observed.

#### Scenario: Toggling GPU driver saves OptiScaler INI
- **WHEN** the test runner clicks the "OptiScaler" tab and switches the driver from MESA to NVIDIA using DPI-scaled coordinates and a vertical sweep of mouse click positions
- **THEN** GOverlay silently saves `OptiScaler.ini` with `ForceReflex=false` and `SpoofDLSS=false`.

#### Scenario: Main save button writes config files
- **WHEN** the test runner edits settings on a tab and clicks the "Save" button using DPI-scaled coordinates
- **THEN** GOverlay writes the final configuration files, and a desktop notification/console output is captured.
