# download-progress-display Specification

## Purpose
Defines the placement and display behavior of download and component update progress across all tabs, ensuring progress indicators are integrated into their respective card sections without redundant floating banners.

## Requirements

### Requirement: In-Card Progress for Component Updates
The system SHALL display download and installation progress for OptiScaler and DLSS-Enabler exclusively within the Software Status card using its integrated progress bar and status label.

#### Scenario: Component update started
- **WHEN** user initiates an OptiScaler or DLSS-Enabler update from the Software Status card
- **THEN** progress and status are reported solely through the integrated progress bar and status label within the card, and no floating progress banner is rendered on screen.

#### Scenario: Component update finishes
- **WHEN** the component update completes or terminates
- **THEN** the integrated progress controls are hidden and the update buttons are restored without invoking any floating progress banner lifecycle methods.

### Requirement: In-Card Progress for ReShade Shaders
The system SHALL display download and sync progress for ReShade shaders exclusively within the vkBasalt toggle card controls.

#### Scenario: ReShade shader download or sync commences
- **WHEN** ReShade shaders are downloaded or synced from the vkBasalt configuration tab
- **THEN** progress percentage and phase text are reported solely through the toggle card progress bar and label, and no floating progress banner is rendered on screen.
