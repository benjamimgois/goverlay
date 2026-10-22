# missing-dependency-warning-banners Specification

## Purpose
Provides visible warning banners and control deactivation when required system runtimes or packages are not installed, preventing user confusion and offering direct installation instructions.

## Requirements

### Requirement: MangoHud missing dependency banner and control deactivation
The system SHALL detect when the MangoHud binary or Flatpak extension runtime is not available on the system, display a warning banner at the top of the MangoHud tab view, deactivate the MangoHud configuration controls, and disable the Save button.

#### Scenario: MangoHud is not installed
- **WHEN** user opens the MangoHud tab and neither native `mangohud` nor the MangoHud Flatpak runtime extension is detected
- **THEN** the MangoHud warning banner is displayed, MangoHud configuration controls are disabled, and the Save button is disabled

#### Scenario: MangoHud is installed
- **WHEN** user opens the MangoHud tab and MangoHud is properly installed
- **THEN** no warning banner is displayed, configuration controls are enabled, and normal saving functionality is permitted

### Requirement: vkBasalt method-specific missing dependency banner and card deactivation
The system SHALL detect when the selected Post Processing method is vkBasalt and its Vulkan layer or package is missing, display a warning banner within the vkBasalt section, deactivate the vkBasalt configuration cards, and disable the Save button.

#### Scenario: vkBasalt method selected and vkBasalt is missing
- **WHEN** user selects the vkBasalt method under the Post Processing tab and the vkBasalt layer/library is not installed
- **THEN** the vkBasalt warning banner is displayed, the vkBasalt configuration cards are disabled, and the Save button is disabled

#### Scenario: Switching method away from vkBasalt
- **WHEN** user switches the Post Processing method to ReShade or None
- **THEN** the vkBasalt warning banner is hidden and controls appropriate to the chosen method are shown

### Requirement: Actionable banner guidance and navigation
The system SHALL present environment-aware installation instructions in the warning banner, including the Flatpak extension command when running in Flatpak, a button to open the system status diagnostics, and a button to re-check dependencies.

#### Scenario: Flatpak environment guidance
- **WHEN** the application is running inside Flatpak and a required runtime is missing
- **THEN** the banner displays the exact `flatpak install` command for the missing runtime extension

#### Scenario: View Status navigation
- **WHEN** user clicks the "View Status" button on the warning banner
- **THEN** the application switches to the Home / Status diagnostics screen

#### Scenario: Re-check dependencies
- **WHEN** user clicks the "Re-check" button on the warning banner
- **THEN** the application re-evaluates system dependencies and updates banner visibility and control states immediately

### Requirement: vkSumi subtab missing dependency banner and card deactivation
The system SHALL detect when vkSumi or its Vulkan layer runtime is missing, display a warning banner at the top of the vkSumi tab, deactivate the vkSumi configuration cards, and disable the Save button.

#### Scenario: vkSumi tab active and vkSumi missing
- **WHEN** user opens the vkSumi sub-tab and vkSumi is not installed
- **THEN** the vkSumi warning banner is displayed, its configuration cards are disabled, and the Save button is disabled

#### Scenario: vkSumi tab active and vkSumi installed
- **WHEN** user opens the vkSumi sub-tab and vkSumi is installed
- **THEN** the vkSumi warning banner is hidden and controls are enabled

### Requirement: Tweaks on-hover missing dependency banner and option blocking
The system SHALL detect when Korthos low latency (`vulkan-low-latency-layer`) or `gamemode` is missing, display the warning banner on-demand when hovering over the affected tweak options, and prevent toggling the missing tweak options with user-friendly alerts.

#### Scenario: Hovering over Korthos low latency items when missing
- **WHEN** user hovers over any Korthos low latency tweak row and `vulkan-low-latency-layer` is missing
- **THEN** the warning banner appears with instructions for `vulkan-low-latency-layer`

#### Scenario: Hovering over GameMode when missing
- **WHEN** user hovers over `#gamemode` and `gamemode` is missing
- **THEN** the warning banner appears with instructions for `gamemode`

#### Scenario: Mouse leaves missing dependency item
- **WHEN** user moves the mouse away from the item or leaves the tweaks view
- **THEN** the warning banner is automatically hidden
