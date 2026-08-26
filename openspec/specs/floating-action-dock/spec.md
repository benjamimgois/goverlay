# floating-action-dock Specification

## Purpose
Provides a unified, modern floating action dock (pill-style bar) anchored in the bottom-right corner of GOverlay, hosting contextual quick-action buttons across all configuration tabs.

## Requirements

### Requirement: Floating Action Dock Rendering and Positioning
The system SHALL display a floating action pill dock anchored at the bottom-right corner of the main content area, rendered with 100% transparent corners outside the pill shape, exact semicircular pill curvature without hard black drop shadows or dark corner cutouts, seamless container background blending matching the active interface theme, an integrated solid blue primary Finish action section occupying the right side of the dock, and state-aware custom-rendered secondary action buttons with illuminated hover and pressed styling.

#### Scenario: Displaying floating action dock
- **WHEN** GOverlay main window is displayed
- **THEN** the floating action dock SHALL be anchored at the bottom-right above tab content, rendering completely clean semicircular rounded ends without black drop shadow artifacts, dark bounding boxes, or chamfered corners.

#### Scenario: Hovering over Finish action button
- **WHEN** user hovers the mouse over the primary Finish action button
- **THEN** the button SHALL illuminate with a brighter, more vibrant blue/cyan fill while preserving white text contrast.

#### Scenario: Pressing Finish action button
- **WHEN** user presses the primary Finish action button
- **THEN** the button SHALL render an active deeper pressed state for immediate tactile feedback.

#### Scenario: Hovering over secondary action buttons
- **WHEN** user hovers the mouse over any secondary button (Menu, Preview, Add)
- **THEN** the button SHALL render a distinct elevated slate chip background with crisp white text.

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

### Requirement: Permanent Suppression of Legacy Bottom Bar
The system SHALL keep the legacy bottom bar (`goverlaybarPanel`) and embedded command panel (`commandPanel`) permanently hidden across all navigation actions, game card selections, and configuration save operations, relying exclusively on the floating action dock for actions and the Finish dialog for launch options.

#### Scenario: Selecting a game from Games tab
- **WHEN** user selects a game card from the Games tab to edit its configuration
- **THEN** GOverlay SHALL activate the floating action dock for MangoHud and keep the legacy bottom bar and command panel hidden (`Visible = False`).

#### Scenario: Saving configuration
- **WHEN** user saves configuration settings across any tab or profile mode
- **THEN** GOverlay SHALL display the floating auto-save toast and maintain the legacy bottom bar and command panel in hidden state.
