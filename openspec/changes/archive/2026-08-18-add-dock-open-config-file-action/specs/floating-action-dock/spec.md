## MODIFIED Requirements

### Requirement: Contextual Action Buttons in Dock
The system SHALL present action controls within the floating action dock according to the capabilities of the currently active tab.

#### Scenario: Viewing tabs with 3D overlay support
- **WHEN** user is on MangoHud, vkBasalt, vkSumi, or Lossless Scaling tabs
- **THEN** the dock SHALL display the 3D Preview button (`▶`), the Menu button (`☰`), and the primary Finish Config button (`Finish Config`).

#### Scenario: Viewing tabs without 3D overlay support
- **WHEN** user is on OptiScaler or EnvVars tabs
- **THEN** the dock SHALL hide the 3D Preview button (`▶`) and adjust its compact pill width while keeping the Menu button (`☰`) and the Finish Config button (`Finish Config`) visible, showing `+ Add` on EnvVars.

#### Scenario: Viewing Games tab
- **WHEN** user is on the Games tab
- **THEN** the dock SHALL display the Menu button (`☰`) and the Add button with caption `+ Add Folder`, while hiding the 3D Preview button and the Finish Config button.

### Requirement: Action Button Interactions
The system SHALL execute corresponding workflows when floating dock buttons are clicked.

#### Scenario: Clicking Preview button
- **WHEN** user clicks the Preview button in the floating dock
- **THEN** GOverlay SHALL launch the 3D preview benchmark (pascube or vkcube) according to the configured overlay settings.

#### Scenario: Clicking Menu button
- **WHEN** user clicks the Menu button in the floating dock
- **THEN** GOverlay SHALL display the contextual options popup menu for the active tab (including non-Steam folder management and library refresh on Games tab).

#### Scenario: Clicking Finish Config button
- **WHEN** user clicks the Finish Config button in the floating dock
- **THEN** GOverlay SHALL open the Finish Configuration and Launch Setup dialog.

#### Scenario: Clicking Add Folder button on Games tab
- **WHEN** user clicks the Add Folder button in the floating dock while on the Games tab
- **THEN** GOverlay SHALL open the directory picker dialog to select and add a non-Steam game folder.

#### Scenario: Selecting Open Config File from Hamburger Menu
- **WHEN** user opens the floating dock hamburger menu (`☰`) on any configuration tab (MangoHud, vkBasalt, vkSumi, OptiScaler, Lossless Scaling, EnvVars) and selects "Open config file"
- **THEN** GOverlay SHALL resolve the active tab's target configuration file (`MangoHud.conf`, `vkBasalt.conf`, `vkSumi.conf`, `OptiScaler.ini`, `lsfg.toml`, or `bgmod.conf`), create/save the file if not already present on disk, and open it in the default desktop text editor.
