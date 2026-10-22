## Purpose

Provides automated detection of legacy `lsfg-vk 1.x` files, unmigrated Steam Lossless Scaling installations, and an interactive assistant dialog to guide users through required migration steps and elevated cleanup.

## ADDED Requirements

### Requirement: Non-blocking migration health detection
The system SHALL inspect filesystem state during Lossless Scaling initialization and tab activation to detect migration hazards without blocking the user interface.

#### Scenario: Detecting unmigrated Steam branch
- **WHEN** user configures Lossless Scaling and the detected Lossless directory contains `Lossless.dll` but lacks `lsfg-vk.dll`
- **THEN** system flags the Steam branch health state as requiring user migration to the `lsfg-vk` beta branch.

#### Scenario: Detecting legacy 1.x system layers
- **WHEN** the system scans Vulkan layer directories and detects `/etc/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json`, `/usr/lib/liblsfg-vk.so`, or `/usr/lib64/liblsfg-vk.so`
- **THEN** system flags the presence of conflicting legacy 1.x system layers.

#### Scenario: Detecting outdated user configuration
- **WHEN** `~/.config/lsfg-vk/conf.toml` exists and contains `version = 1` or `[[game]]` blocks
- **THEN** system flags user configuration as requiring schema modernization.

### Requirement: Lossless Scaling tab migration alert banner
The system SHALL display an alert banner at the top of the Lossless Scaling tab whenever one or more migration hazards are detected.

#### Scenario: Viewing tab with migration hazards
- **WHEN** user navigates to the Lossless Scaling tab with active migration hazards
- **THEN** system displays an amber/warning alert banner summarizing detected hazards and providing a button labeled "Fix Issues" or "Migration Assistant".

#### Scenario: Viewing tab when all checks pass
- **WHEN** user navigates to the Lossless Scaling tab and all migration checks are healthy
- **THEN** system does not display the migration alert banner.

### Requirement: Interactive Migration and Health Assistant dialog
The system SHALL present an interactive dialog explaining the migration steps, guiding the user through Steam beta selection, elevated cleanup, and configuration reset.

#### Scenario: User clicks Fix Issues
- **WHEN** user clicks the "Fix Issues" button in the migration alert banner
- **THEN** system opens the Migration and Health Assistant dialog displaying real-time status indicators (Pass/Warning/Fail) for Steam branch, legacy system files, user configuration, and distro package recommendations.

#### Scenario: User opens Lossless Scaling Steam folder
- **WHEN** user clicks "Open Folder" in the Steam Branch section of the dialog
- **THEN** system opens the Lossless Scaling installation folder in the system default file manager.

### Requirement: Elevated legacy system layer cleanup
The system SHALL provide an action in the assistant dialog to remove conflicting legacy 1.x system files using elevated privileges via `pkexec`.

#### Scenario: User triggers elevated cleanup
- **WHEN** user clicks "Clean Legacy Files" in the Migration Assistant
- **THEN** system executes `pkexec rm -f` targeting known legacy layer manifests and libraries, updating the assistant status to healthy upon successful completion without crashing if authorization is canceled.

### Requirement: User configuration schema migration
The system SHALL automatically back up and reset legacy `~/.config/lsfg-vk/conf.toml` files that use outdated v1 syntax.

#### Scenario: Backing up and refreshing legacy user configuration
- **WHEN** user triggers configuration cleanup in the Migration Assistant
- **THEN** system moves the existing `conf.toml` to `conf.toml.v1.bak` and writes a valid v2 default configuration.

### Requirement: Hamburger popup menu integration
The system SHALL provide a menu entry inside the hamburger popup menu (`popsaveMenu`), positioned directly below "Open log file", to launch the Migration Assistant dialog whenever on the Lossless Scaling tab and `lsfg-vk` is selected.

#### Scenario: Hamburger menu item visibility when lsfg-vk is active on Lossless Scaling tab
- **WHEN** user is on the Lossless Scaling tab and `lsfg-vk` is selected as the method
- **THEN** the hamburger popup menu displays the "lsfg-vk Migration Assistant" item below "Open log file".

#### Scenario: Hamburger menu item hidden when MAKO or None is active or on other tabs
- **WHEN** the active Lossless Scaling method is not `lsfg-vk`, or another tab is active
- **THEN** the "lsfg-vk Migration Assistant" item is hidden from the hamburger popup menu.

#### Scenario: Triggering Migration Assistant from hamburger menu
- **WHEN** user clicks "lsfg-vk Migration Assistant" in the hamburger menu
- **THEN** the system launches the interactive Migration Assistant dialog (`TLSFGVkMigrationDialog`).
